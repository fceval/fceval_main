use super::coverage_utils::{Edge, EdgeRecord};
use super::{AnalysisType, AnalysisUpdate, GlobalState, PassConfig, PassType, SharedLogger};
use crate::fuzzers::FuzzerId;
use std::collections::{HashMap, HashSet};
use core::fmt::Error;
use std::result::Iter;

pub struct FuzzerCoverageState {
    fuzzer_to_coverage: HashMap<FuzzerId, HashSet<Edge>>,
    fuzzer_to_coverage_bb: HashMap<FuzzerId, HashSet<u64>>,//zhaoxy add for basic block coverage
    logger: SharedLogger,
}

impl FuzzerCoverageState {
    pub fn new(_config: &PassConfig, logger: SharedLogger) -> Self {
        Self {
            fuzzer_to_coverage: HashMap::new(),
            fuzzer_to_coverage_bb: HashMap::new(),//zhaoxy add for basic block coverage
            logger,
        }
    }

    #[allow(dead_code)]
    pub fn get_fuzzer_coverage(&self, fuzzer_id: FuzzerId) -> &HashSet<Edge> {
        self.fuzzer_to_coverage
            .get(&fuzzer_id)
            .expect("Invalid fuzzer ID")
    }

    //zhaoxy add custom scheduler
    #[allow(dead_code)]
    pub fn get_fuzzers_coverage(&self) -> &HashMap<FuzzerId, HashSet<Edge>> {
        &self.fuzzer_to_coverage
    }

    //zhaoxy add for basic block coverage start
    #[allow(dead_code)]
    pub fn get_fuzzer_coverage_bb(&self, fuzzer_id: FuzzerId) -> &HashSet<u64> {
        self.fuzzer_to_coverage_bb
            .get(&fuzzer_id)
            .expect("Invalid fuzzer ID")
    }

    #[allow(dead_code)]
    pub fn get_fuzzers_coverage_bb(&self) -> &HashMap<FuzzerId, HashSet<u64>> {
        &self.fuzzer_to_coverage_bb
    }
    //zhaoxy add for basic block coverage end
}

impl GlobalState for FuzzerCoverageState {
    fn analysis_type(&self) -> AnalysisType {
        AnalysisType::FuzzerCoverage
    }

    fn get_required_passes(&self) -> Option<Vec<PassType>> {
        Some(vec![PassType::EdgeTracer])
    }

    fn update(&mut self, update: &AnalysisUpdate) {
        log::debug!("zxy fuzzer_coverage_analysis fuzzerid:{}",update.get_fuzzer_id().as_u32());
        let fuzzer_coverage = if let Some(fuzzer_coverage) =
            self.fuzzer_to_coverage.get_mut(&update.get_fuzzer_id())
        {
            //log::debug!("zxy fuzzer_coverage_analysis 1111111111 fuzzerid:{}",update.get_fuzzer_id().as_u32());
            fuzzer_coverage
        } else {
            //log::debug!("zxy fuzzer_coverage_analysis2222222222 fuzzerid:{}",update.get_fuzzer_id().as_u32());
            let fuzzer_coverage = HashSet::new();
            self.fuzzer_to_coverage
                .insert(update.get_fuzzer_id(), fuzzer_coverage);

            self.fuzzer_to_coverage
                .get_mut(&update.get_fuzzer_id())
                .unwrap() 
        };


        //zhaoxy add for basic block coverage start
        let fuzzer_coverage_bb = if let Some(fuzzer_coverage_bb) =
            self.fuzzer_to_coverage_bb.get_mut(&update.get_fuzzer_id())
         {
            //log::debug!("zxy fuzzer_coverage_analysis 1111111111 fuzzerid:{}",update.get_fuzzer_id().as_u32());
            fuzzer_coverage_bb
         } else {
            //log::debug!("zxy fuzzer_coverage_analysis2222222222 fuzzerid:{}",update.get_fuzzer_id().as_u32());
            let fuzzer_coverage_bb = HashSet::new();
            self.fuzzer_to_coverage_bb
                .insert(update.get_fuzzer_id(), fuzzer_coverage_bb);

            self.fuzzer_to_coverage_bb
                .get_mut(&update.get_fuzzer_id())
                .unwrap() 
        };
         //zhaoxy add for basic block coverage end

        let tracer_output = update.get_pass_result(PassType::EdgeTracer);
        let mut reader = csv::Reader::from_reader(tracer_output.as_slice());
        let mut diff = HashSet::new();
        for result in reader.deserialize() {
            // println!("Could not parse CSV entry22222222222222222");
            //zhaoxy modify 2022091701 for panic:Error(UnequalLengths { pos: Some(Position { byte: 8183, line: 481, record: 480 }), expected_len: 3, len: 2 })' begin
            //let edge_record: EdgeRecord = result.expect("Could not parse CSV entry");
            let edge_record: Result<EdgeRecord, csv::Error> = result;
            // println!("Could not parse CSV entry1111111111111");
            match edge_record {
                Ok(file) => {
                    // println!("Could not parse CSV entry33333333333333333");
                    let edge = Edge::from(file);
                    // println!("Could not parse CSV entry555555555555555");
                    //zhaoxy add for basic block coverage 
                    fuzzer_coverage_bb.insert(edge.get_source());
                    fuzzer_coverage_bb.insert(edge.get_target());
                    // println!("Could not parse CSV entry4444444444444444444");
        
                    if fuzzer_coverage.insert(edge) {
                        diff.insert(edge);
                    }
                },
                Err(error) => println!("fuzzer Could not parse CSV entry")
            };
            //let edge_record: EdgeRecord = result.unwrap_or_else(|error|{println!("Could not parse CSV entry")});
            // let edge = Edge::from(edge_record);

            // //zhaoxy add for basic block coverage 
            // fuzzer_coverage_bb.insert(edge.get_source());
            // fuzzer_coverage_bb.insert(edge.get_target());

            // if fuzzer_coverage.insert(edge) {
            //     diff.insert(edge);
            // }
            //zhaoxy modify 2022091701 for panic:Error(UnequalLengths { pos: Some(Position { byte: 8183, line: 481, record: 480 }), expected_len: 3, len: 2 })' end
        }

        //zhaoxy modify for storaging edge coverage start
        if 0==diff.len(){ //avoid inessential time-consuming
            return;
        }

        for edge_diff in diff.clone(){
            self.logger.lock().unwrap().log_edge_coverage_fuzzer(update.get_test_handle().clone(),update.get_fuzzer_id(),edge_diff);
        }
        //zhaoxy modify for storaging edge coverage end

        let diff_vec = serde_cbor::to_vec(&(update.get_fuzzer_id(), diff))
            .expect("Failed to serialize analysis");
        if let Err(e) = self.logger.lock().unwrap().log_analysis_state(
            update.get_test_handle().clone(),
            update.get_fuzzer_id(),
            self.analysis_type(),
            diff_vec,
        ) {
            log::error!("Failed to log analysis state: {}", e);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::fuzzers::FuzzerId;
    use crate::logger::tests::{cleanup as logger_cleanup, create_shared_logger};
    use crate::storage::TestCaseHandle;
    use std::env;
    use std::fs;
    use std::fs::File;
    use std::io::Read;
    use std::path::PathBuf;

    #[test]
    fn test_fuzzer_coverage_analysis() {
        let binaries_dir = PathBuf::from(env!("ANALYSIS_BINARIES_OBJDUMP_PATH"));
        let empty_path = PathBuf::from("tests/assets/empty");

        let temp_dir = env::temp_dir()
            .join("pass_tests")
            .join("fuzzer_coverage_pass");
        fs::create_dir_all(&temp_dir).unwrap();

        let config = PassConfig {
            program_arguments: vec![String::from("-d"), String::from("@@")],
            analysis_artifacts_dir: binaries_dir,
            analysis_input_dir: temp_dir,
        };
        let edge_tracer_pass = PassType::EdgeTracer.get_pass(config.clone()).unwrap();

        let mut test_case_file = File::open(empty_path).unwrap();
        let mut test_case = Vec::new();
        test_case_file.read_to_end(&mut test_case).unwrap();
        let output = edge_tracer_pass
            .process(&test_case)
            .expect("process failed");

        let test_handle = TestCaseHandle::get_fake_handle("");
        let fuzzer_id = FuzzerId::new(42);

        let logger_output_dir = "test_fuzzer_coverage_pass";
        let mut fuzzer_coverage_state =
            FuzzerCoverageState::new(&config, create_shared_logger(logger_output_dir));
        let mut update = AnalysisUpdate::new(test_handle.clone(), fuzzer_id, Vec::new());
        update.add_pass_result(PassType::EdgeTracer, output);
        fuzzer_coverage_state.update(&update);

        let fuzzer_coverage = fuzzer_coverage_state.get_fuzzer_coverage(fuzzer_id);

        let test_edge = Edge::new(0x6d5, 0x6e3);
        let assert_value = fuzzer_coverage.contains(&test_edge);
        if !assert_value {
            println!("test_edge: {:?}", test_edge);
            println!("fuzzer_coverage: {:?}", fuzzer_coverage);
        }

        assert!(assert_value);

        logger_cleanup(logger_output_dir);
    }
}
