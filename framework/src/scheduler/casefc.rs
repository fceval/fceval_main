use super::util::{QueueSchedulerConfig, QueueSchedulerHelper, SchedulerFacadeRef};
use super::{ScheduleMessage, Scheduler};
use crate::analysis::coverage_utils::Edge;
use crate::fuzzers::{FuzzerId, FuzzerType, FuzzersHandler};//zhaoxy add custom scheduler
use crate::analysis::AnalysisType;
use crate::types::SeedType;//zhaoxy add for crash testcase shecule
use crate::analysis::GlobalCoverageState;
use crate::analysis::FuzzerCoverageState;//zhaoxy add custom scheduler
use crate::analysis::FuzzerIdState;//zhaoxy add custom scheduler
use crate::storage::TestCaseHandle;
use priority_queue::PriorityQueue;
use rand::random;
use std::collections::{HashMap, HashSet};
use std::string;
use std::sync::{Arc, Mutex};
use cadence::prelude::*;
use std::net::UdpSocket;
use std::time::Duration;
use cadence::{StatsdClient, UdpMetricSink};
use std::time::SystemTime;


// use chrono::offset::Local;
// use chrono::DateTime;
//zhaoxy add new custom scheduler
//idea:some fuzzer combinations may not produce new test cases that can improve global coverage,
//leading to no seed sharing between them and combinations fade back to single fuzzers
//just at this monent,we should share all testcases between them even if they couldn't improve global coverage
//then,if new coverage gained again,prioritize testcases that cover new branches. 

pub const SCHEDULER_NAME: &str = "casefc";

pub struct CasefcScheduler {
    facade_ref: Arc<Mutex<SchedulerFacadeRef>>,  //arc for clone,mutext for multithread
    prev_coverage: HashSet<Edge>,   //no duplicate
    prev_coverage_fuzzers: HashMap<FuzzerId, HashSet<Edge>>,//zhaoxy add custom scheduler
    scheduling_queue: Arc<Mutex<PriorityQueue<TestCaseHandle, usize>>>,
    _helper: QueueSchedulerHelper,
    client:StatsdClient,  //zhaoxy add for statsd coverage
    global_disp:u32,
}

 

impl CasefcScheduler {
    pub fn new(facade_ref: SchedulerFacadeRef) -> Self {
        let facade_ref = Arc::new(Mutex::new(facade_ref));
        let scheduling_queue = Arc::new(Mutex::new(PriorityQueue::new()));

        let helper_config = QueueSchedulerConfig {
            interval: Duration::from_secs(120),
            percentage: 1.,
            allow_env_override: false,
        };

        let helper = QueueSchedulerHelper::new(&facade_ref, &scheduling_queue, Some(helper_config));
        //zhaoxy add for statsd coverage start
        let prefix = "fuzzing"; 
        let host = ("172.24.0.3", 9125);//8125
        let socket = UdpSocket::bind("0.0.0.0:0").unwrap();
        let sink = UdpMetricSink::from(host,socket).unwrap();
        let _client = StatsdClient::from_sink(prefix, sink);
        let prev_coverage_fuzzers:HashMap<FuzzerId, HashSet<Edge>> = HashMap::new();
        //zhaoxy add for statsd coverage end
        let global_id = random();
        // let ct = SystemTime::now();
        // let dt: DateTime<Local> = ct.into(); 
        // let global_id = format!("{}\t", dt.format("%Y%m%d %T"));

        Self {
            facade_ref,
            prev_coverage: HashSet::new(),
            prev_coverage_fuzzers,//zhaoxy add custom scheduler
            scheduling_queue,
            _helper: helper,
            client:_client,  //zhaoxy add for statsd coverage end
            global_disp:global_id
        }
    }
}

impl Scheduler for CasefcScheduler {
    fn schedule(&mut self, schedule_message: ScheduleMessage) {
        let test_handle = match schedule_message {
            ScheduleMessage::Timeout => {
                log::debug!("Do nothing on timeout");
                return;
            }
            ScheduleMessage::DuplicateTestCase(_) => {
                log::debug!("Duplicate test case reported, ignoring");
                return;
            }
            ScheduleMessage::NewTestCase(test_handle) => {
                log::debug!("New seed reported, running");
                test_handle
            }
        };

        // Preserve the order on the scheduling thread to avoid deadlocks
        let facade_ref = self.facade_ref.lock().unwrap();
        let mut scheduling_queue = self.scheduling_queue.lock().unwrap();

        let mut facade = facade_ref.get_facade();

        let edge_tracer_global_state = facade
            .get_analysis_state(AnalysisType::GlobalCoverage)
            .downcast_ref::<GlobalCoverageState>()
            .unwrap();

        let new_coverage = edge_tracer_global_state.get_global_coverage();
        let coverage_increment = new_coverage.difference(&self.prev_coverage);

        
        if coverage_increment.count() == 0  {
            let fuzzer_id_state = facade
            .get_analysis_state(AnalysisType::FuzzerId)
            .downcast_ref::<FuzzerIdState>()
            .unwrap();

            let sender_id = *fuzzer_id_state
                .get_fuzzer_ids(&test_handle)
                .unwrap_or_else(|| {
                    panic!(
                        "Failed to retrieve fuzzer id for test case {}",
                        test_handle.get_unique_id()
                    )
                })
                .last()
                .unwrap_or_else(|| {
                    panic!(
                        "Failed to retrieve fuzzer id for test case {}",
                        test_handle.get_unique_id()
                    )
                });

            let sender_type = facade
                .get_fuzzer_type(sender_id)
                // .expect(&format!("Failed to get fuzzer type for fuzzer id {}", sender_id));
                // .unwrap_or_else(|| panic!("Failed to get fuzzer type for fuzzer id {}", sender_id));
                //to avoid test interrupt by panic
                .unwrap_or_else(|| {
                    log::debug!("Failed to get fuzzer type for fuzzer id {}", sender_id);
                    return FuzzerType::Unknown;
                });
            if sender_type == FuzzerType::Unknown {
                return;
            }
                

            let skip_types = facade.get_available_fuzzers_edge();
            if skip_types.contains(&sender_type) {  //no new global edge coverage,but the sender is either edge-coverage-guided or basic-block-coverage-guided
                log::debug!(
                    "when no global coverage improved,Skipping test case from sender {} ({})",
                    sender_id,
                    sender_type
                );
                return;
            }

            log::debug!("zxy no gllobal coverage increases,Queuing test case");
            scheduling_queue.push(test_handle, 0);//zhaoxy add this 
            return;

        }else{ //coverage_increment.count()
                   
            //zhaoxy add for statsd coverage start
            log::debug!("zxy print coverage for casefczxy.rs:{}",new_coverage.len());//zhaoxy add for branch coverage
            let len = new_coverage.len();//usize
            //log::debug!("zxy print coverage start rsrsrsrsrsrsportport {}",DEFAULT_PORT);
            
            self.client.gauge_with_tags("casefc.fuzzing_center.coverage", len as u64)
            .with_tag("fuzzer", format!("global{}",self.global_disp).as_str())
            .with_tag_value("centermetric")
            .try_send().expect("fuzing center coverage global send error");
            self.prev_coverage = new_coverage.clone();


            //zhaoxy add custom scheduler start
            let new_edge_tracer_fuzzers_state = facade
            .get_analysis_state(AnalysisType::FuzzerCoverage)
            .downcast_ref::<FuzzerCoverageState>()
            .unwrap();

            for (fuzzer_id, fuzzer_edges_cover) in new_edge_tracer_fuzzers_state.get_fuzzers_coverage() {
                
                if self.prev_coverage_fuzzers.contains_key(fuzzer_id) {
                //log::debug!("New test ca{}------{:?}, ignoring",fuzzer_id,self.prev_coverage_fuzzers[fuzzer_id]);
                    let fuzzer_edges_coverage_increment = fuzzer_edges_cover.difference(&self.prev_coverage_fuzzers[fuzzer_id]);
                    if fuzzer_edges_coverage_increment.count() == 0 {
                        log::debug!("New test case did not produce new coverage for fuzzer{}, ignoring",fuzzer_id.as_u32());
                        continue;
                    }
                }

                //for cover_tmp in fuzzer_edges_cover {
                //   self.prev_coverage_fuzzers[fuzzer_id].em
                //} 
                //self.prev_coverage_fuzzers.get_mut(fuzzer_id) =  fuzzer_edges_cover.clone();
                log::debug!("zxy print coverage for casefczxy fuzzer{}:{}",fuzzer_id.as_u32(),fuzzer_edges_cover.len());//zhaoxy add for branch coverage
                let len = fuzzer_edges_cover.len();//usize
                //log::debug!("zxy print coverage start rsrsrsrsrsrsportport {}",DEFAULT_PORT);
                self.client.gauge_with_tags("casefc.fuzzing_center.coverage", len as u64)
                .with_tag("fuzzer", fuzzer_id.to_string().as_str())
                .with_tag_value("centermetric")
                .try_send().expect("fuzing center coverage send error");
                //self.client.count("coverage.branches",fuzzer_edges_cover.len() as i64).expect("zxy send number of branches for fuzzer error"); 
            }
            self.prev_coverage_fuzzers =  new_edge_tracer_fuzzers_state.get_fuzzers_coverage().clone();

      
            //modify for pass testcases to all available fuzzers,not only edge-guided ones and put it in scheduling_queue start
            for fuzzer_type in facade.get_available_fuzzers() {//broadcast testcases to all available fuzzers
                log::debug!("Dispatching to {:?}", fuzzer_type);
    
                if let Err(e) =
                    facade.dispatch_test_cases_to_all(vec![test_handle.clone()], fuzzer_type)
                {
                    log::error!("Error while dispatching seed: {}", e);
                }
            }

        } //end of else coverage_increment.count()
    }//end of fn schedule
}//end of impl Scheduler
