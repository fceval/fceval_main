use super::util::{QueueSchedulerConfig, QueueSchedulerHelper, SchedulerFacadeRef};
use super::{ScheduleMessage, Scheduler};
use crate::analysis::coverage_utils::Edge;
use crate::analysis::AnalysisType;
use crate::analysis::GlobalCoverageState;
use crate::storage::TestCaseHandle;
use priority_queue::PriorityQueue;
use std::collections::HashSet;
use std::sync::{Arc, Mutex};

use cadence::prelude::*;
use std::net::UdpSocket;
use std::time::{Duration};
use cadence::{StatsdClient, UdpMetricSink, DEFAULT_PORT};

use rand::random;

pub const SCHEDULER_NAME: &str = "enfuzz";

pub struct EnFuzzScheduler {
    facade_ref: Arc<Mutex<SchedulerFacadeRef>>,
    prev_coverage: HashSet<Edge>,
    scheduling_queue: Arc<Mutex<PriorityQueue<TestCaseHandle, usize>>>,
    _helper: QueueSchedulerHelper,
    client:StatsdClient,  //zhaoxy add for statsd coverage
    global_disp:u32,
}

 

impl EnFuzzScheduler {
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

        //zhaoxy add for statsd coverage end
        let global_id = random();
        // let ct = SystemTime::now();
        // let dt: DateTime<Local> = ct.into(); 
        // let global_id = format!("{}\t", dt.format("%Y%m%d %T"));

        Self {
            facade_ref,
            prev_coverage: HashSet::new(),
            scheduling_queue,
            _helper: helper,
            client:_client,  //zhaoxy add for statsd coverage end
            global_disp:global_id
        }
    }
}

impl Scheduler for EnFuzzScheduler {
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

        let facade = facade_ref.get_facade();

        let edge_tracer_global_state = facade
            .get_analysis_state(AnalysisType::GlobalCoverage)
            .downcast_ref::<GlobalCoverageState>()
            .unwrap();

        let new_coverage = edge_tracer_global_state.get_global_coverage();
        let coverage_increment = new_coverage.difference(&self.prev_coverage);
        
        if coverage_increment.count() == 0 {
            log::debug!("New test case did not produce new coverage, ignoring");
            return;
        } 
        
        //zhaoxy add for statsd coverage start
        log::debug!("zxy print coverage for enfuzz.rs:{}",new_coverage.len());//zhaoxy add for branch coverage
        let len = new_coverage.len();//usize
        self.client.gauge_with_tags("enfuzz.fuzzing_center.coverage", len as u64)
        .with_tag("fuzzer", format!("global{}",self.global_disp).as_str())
        .with_tag_value("centermetric")
        .try_send().expect("enfuzz fuzing center coverage global send error");
        //zhaoxy add for statsd coverage end
 
        

        self.prev_coverage = new_coverage.clone();

        log::debug!("Queuing test case");
        scheduling_queue.push(test_handle, 0);
    }
}
