use crate::analysis::AnalysisType;
use crate::fuzzers::FuzzerType;
use crate::storage::TestCaseHandle;
use std::error;
use std::fmt;
use std::str::FromStr;

mod util;
pub use self::util::{SchedulerFacadeRef, SchedulerHandler, SchedulerHandlerControlMessage};

// Add your module here and import your scheduler
mod test;
use test::TestScheduler;

mod enfuzz;
use enfuzz::EnFuzzScheduler;


//zhaoxy add custom scheduler
 
mod htfuzzzxy;
use htfuzzzxy::HtfuzzzxyScheduler;

//zhaoxy add new custom scheduler
//idea:some fuzzer combinations may not produce new test cases that can improve global coverage,
//leading to no seed sharing between them and combinations fade back to single fuzzers
//just at this monent,we should share all testcases between them even if they couldn't improve global coverage
//then,if new coverage gained again,prioritize testcases that cover new branches. 
mod casefc;
use casefc::CasefcScheduler;

mod broadcast;
use broadcast::BroadcastScheduler;

mod selective;
use selective::SelectiveScheduler;

mod random;
use random::RandomScheduler;

mod roundrobin;
use roundrobin::RoundRobinScheduler;

mod nop;
use nop::NopScheduler;

mod test_case_benefit;
use test_case_benefit::TestCaseBenefitScheduler;

mod hybrid_benefit;
use hybrid_benefit::HybridBenefitScheduler;

mod cost_benefit;
use cost_benefit::CostBenefitScheduler;

mod regressor;
use regressor::RegressorScheduler;

pub enum ScheduleMessage {
    Timeout,
    NewTestCase(TestCaseHandle),
    DuplicateTestCase(TestCaseHandle),
}

pub trait Scheduler {
    fn schedule(&mut self, new_seed: ScheduleMessage);
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum SchedulerType {
    // Add a value to this enumeration for the type of your scheduler
    Test,
    EnFuzz,
    Broadcast,
    Selective,
    Random,
    RoundRobin,
    Nop,
    TestCaseBenefit,
    HybridBenefit,
    CostBenefit,
    Regressor,
    Stats,
    //zhaoxy add custom scheduler
    Htfuzzzxy,
    CasefcScheduler,//zhaoxy add new custom scheduler
}

impl SchedulerType {
    pub fn get_requirements(self) -> Vec<AnalysisType> {
        // Add a case to this match to define the requirements for a new scheduler
        match self {
            SchedulerType::Test => vec![AnalysisType::Test],
            SchedulerType::EnFuzz => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::FuzzerCoverage,
                AnalysisType::FuzzerId,
            ],
            SchedulerType::Broadcast => vec![AnalysisType::GlobalCoverage],
            SchedulerType::Selective => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::FuzzerCoverage,
                AnalysisType::FuzzerId,
            ],
            SchedulerType::Random => vec![AnalysisType::GlobalCoverage],
            SchedulerType::RoundRobin => vec![AnalysisType::GlobalCoverage],
            SchedulerType::Nop => vec![AnalysisType::GlobalCoverage, AnalysisType::FuzzerCoverage],
            SchedulerType::TestCaseBenefit => {
                vec![AnalysisType::GlobalCoverage, AnalysisType::TestCaseBenefit]
            }
            SchedulerType::HybridBenefit => {
                vec![AnalysisType::GlobalCoverage, AnalysisType::TestCaseBenefit]
            }
            SchedulerType::CostBenefit => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::TestCaseBenefit,
                AnalysisType::InstructionCount,
            ],
            SchedulerType::Regressor => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::InstructionCount,
                AnalysisType::ObservedConditions,
                AnalysisType::FuzzerId,
                AnalysisType::RegressorPredictions,
            ],
            SchedulerType::Stats => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::TestCaseBenefit,
                AnalysisType::ObservedConditions,
                AnalysisType::FuzzerObservedConditions,
                // AnalysisType::GenerationGraph,
                AnalysisType::InstructionCount,
                AnalysisType::FuzzerCoverage,
                AnalysisType::FuzzerId,
                AnalysisType::TaintedConditions,
                AnalysisType::ConditionBytes,
            ],
            //zhaoxy add custom scheduler
            SchedulerType::Htfuzzzxy => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::FuzzerCoverage,
                AnalysisType::FuzzerId,
            ], 
            //zhaoxy add new custom scheduler
            SchedulerType::CasefcScheduler => vec![
                AnalysisType::GlobalCoverage,
                AnalysisType::FuzzerCoverage,
                AnalysisType::FuzzerId,
            ],            
        }
    }

    pub fn get_scheduler(self, facade: SchedulerFacadeRef) -> Box<dyn Scheduler> {
        // Add a case to this match to construct an instance of your scheduler
        match self {
            SchedulerType::Test => Box::new(TestScheduler::new(facade)),
            SchedulerType::EnFuzz => Box::new(EnFuzzScheduler::new(facade)),
            SchedulerType::Broadcast => Box::new(BroadcastScheduler::new(facade)),
            SchedulerType::Selective => Box::new(SelectiveScheduler::new(
                facade,
                &[FuzzerType::AFL, FuzzerType::QSYM],
                &[FuzzerType::AFL, FuzzerType::QSYM],
            )),
            SchedulerType::Random => Box::new(RandomScheduler::new(facade)),
            SchedulerType::RoundRobin => Box::new(RoundRobinScheduler::new(facade)),
            SchedulerType::Nop => Box::new(NopScheduler::new(facade)),
            SchedulerType::TestCaseBenefit => Box::new(TestCaseBenefitScheduler::new(facade)),
            SchedulerType::HybridBenefit => Box::new(HybridBenefitScheduler::new(facade)),
            SchedulerType::CostBenefit => Box::new(CostBenefitScheduler::new(facade)),
            SchedulerType::Regressor => Box::new(RegressorScheduler::new(facade)),
            SchedulerType::Stats => Box::new(SelectiveScheduler::new(
                facade,
                &[FuzzerType::AFL, FuzzerType::QSYM],
                &[FuzzerType::AFL, FuzzerType::QSYM],
            )),
            //zhaoxy add custom scheduler
            SchedulerType::Htfuzzzxy => Box::new(HtfuzzzxyScheduler::new(facade)),
            //zhaoxy add new custom scheduler
            SchedulerType::CasefcScheduler => Box::new(CasefcScheduler::new(facade)),            
        }
    }
}

#[derive(Debug)]
pub struct ParseSchedulerError(String);

impl fmt::Display for ParseSchedulerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Unknown scheduler: {}", self.0)
    }
}

impl error::Error for ParseSchedulerError {}

impl FromStr for SchedulerType {
    type Err = ParseSchedulerError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        // Add a case to this match to specify the name of your scheduler
        match s {
            "test" => Ok(SchedulerType::Test),
            enfuzz::SCHEDULER_NAME => Ok(SchedulerType::EnFuzz),
            //zhaoxy add custom scheduler
            htfuzzzxy::SCHEDULER_NAME => Ok(SchedulerType::Htfuzzzxy),
            //zhaoxy add custom scheduler
            casefc::SCHEDULER_NAME => Ok(SchedulerType::CasefcScheduler),            
            broadcast::SCHEDULER_NAME => Ok(SchedulerType::Broadcast),
            selective::SCHEDULER_NAME => Ok(SchedulerType::Selective),
            random::SCHEDULER_NAME => Ok(SchedulerType::Random),
            roundrobin::SCHEDULER_NAME => Ok(SchedulerType::RoundRobin),
            nop::SCHEDULER_NAME => Ok(SchedulerType::Nop),
            test_case_benefit::SCHEDULER_NAME => Ok(SchedulerType::TestCaseBenefit),
            hybrid_benefit::SCHEDULER_NAME => Ok(SchedulerType::HybridBenefit),
            cost_benefit::SCHEDULER_NAME => Ok(SchedulerType::CostBenefit),
            regressor::SCHEDULER_NAME => Ok(SchedulerType::Regressor),
            "stats" => Ok(SchedulerType::Stats),
            _ => Err(ParseSchedulerError(String::from(s))),
        }
    }
}

impl fmt::Display for SchedulerType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // Add a case to this match that is consistent with the one above
        let type_name = match self {
            SchedulerType::Test => "test",
            SchedulerType::EnFuzz => enfuzz::SCHEDULER_NAME,
            //zhaoxy add custom scheduler
            SchedulerType::Htfuzzzxy => htfuzzzxy::SCHEDULER_NAME,
            //zhaoxy add new custom scheduler
            SchedulerType::CasefcScheduler => casefc::SCHEDULER_NAME,
            SchedulerType::Broadcast => broadcast::SCHEDULER_NAME,
            SchedulerType::Selective => selective::SCHEDULER_NAME,
            SchedulerType::Random => random::SCHEDULER_NAME,
            SchedulerType::RoundRobin => roundrobin::SCHEDULER_NAME,
            SchedulerType::Nop => nop::SCHEDULER_NAME,
            SchedulerType::TestCaseBenefit => test_case_benefit::SCHEDULER_NAME,
            SchedulerType::HybridBenefit => hybrid_benefit::SCHEDULER_NAME,
            SchedulerType::CostBenefit => cost_benefit::SCHEDULER_NAME,
            SchedulerType::Regressor => regressor::SCHEDULER_NAME,
            SchedulerType::Stats => "stats",
        };
        assert_eq!(
            self,
            &SchedulerType::from_str(type_name).unwrap(),
            "SchedulerType has wrong name"
        );

        write!(f, "{}", type_name)
    }
}
