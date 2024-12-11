use crate::protos;
use rand::prelude::*;
use serde::Serialize;
use std::collections::{HashMap, VecDeque};
use std::error::Error;
use std::fmt;
use std::mem;
use std::num::ParseIntError;
use std::str::FromStr;
 
#[derive(Clone, Copy, Debug, Hash, Eq, PartialEq, RustcDecodable, RustcEncodable, Serialize)]
pub struct FuzzerId(u32);

impl FuzzerId {
    pub fn as_u32(self) -> u32 {
        self.0
    }
}

#[cfg(test)]
impl FuzzerId {
    pub fn new(id: u32) -> Self {
        Self(id)
    }
}

impl fmt::Display for FuzzerId {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:03}", self.0)
    }
}

impl FromStr for FuzzerId {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let res = s.parse::<u32>()?;
        Ok(FuzzerId(res))
    }
}

#[derive(Debug)]
struct FuzzersHandlerError(String);

impl fmt::Display for FuzzersHandlerError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "FuzzersHandler error: {}", self.0)
    }
}

impl Error for FuzzersHandlerError {}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum FuzzerType {
    Unknown = 0,
    AFL = 1,
    ANGORA = 2,//zhaoxy add for angora
    QSYM = 3,
    LIBFUZZER = 4,
    HONGGFUZZ = 5,
    AFLFAST = 6,
    FAIRFUZZ = 7,
    RADAMSA = 8,
    AFLPPZXY = 9,
    SYMCC = 10,  //zhaoxy add for symcc
    PARMESAN = 11, //zhaoxy add for parmesan
    AFLPLUSPLUS = 12,  //zhaoxy add for aflplusplus
    MOPT = 13,  //zhaoxy add for MOPT
}

pub fn get_fuzzer_types() -> Vec<FuzzerType> {
    vec![
        FuzzerType::Unknown,
        FuzzerType::AFL,
        FuzzerType::ANGORA,  //zhaoxy add for angora
        FuzzerType::QSYM,
        FuzzerType::LIBFUZZER,
        FuzzerType::HONGGFUZZ,
        FuzzerType::AFLFAST,
        FuzzerType::FAIRFUZZ,
        FuzzerType::RADAMSA,
        FuzzerType::AFLPPZXY,
        FuzzerType::SYMCC,  //zhaoxy add for symcc
        FuzzerType::PARMESAN,  //zhaoxy add for parmesan 
        FuzzerType::AFLPLUSPLUS,  //zhaoxy add for aflplusplus
        FuzzerType::MOPT,  //zhaoxy add for aflplusplus
    ]
}

//zhaoxy add for basic block coverage start
pub fn get_fuzzer_edge_types() -> Vec<FuzzerType> {
    vec![
        FuzzerType::AFL,      
        FuzzerType::AFLFAST,
        FuzzerType::FAIRFUZZ,
        FuzzerType::RADAMSA,
        FuzzerType::AFLPPZXY,
        FuzzerType::HONGGFUZZ,
        FuzzerType::LIBFUZZER,
        FuzzerType::AFLPLUSPLUS,  //zhaoxy add for aflplusplus
        FuzzerType::MOPT,  //zhaoxy add for aflplusplus
    ]
}
pub fn get_fuzzer_bb_types() -> Vec<FuzzerType> {
    vec![
        FuzzerType::HONGGFUZZ,
        FuzzerType::LIBFUZZER,
    ]
}
pub fn get_fuzzer_other_types() -> Vec<FuzzerType> {
    vec![
        FuzzerType::Unknown,
        FuzzerType::QSYM,
        FuzzerType::SYMCC,  //zhaoxy add for symcc
        FuzzerType::PARMESAN,  //zhaoxy add for parmesan 
        FuzzerType::ANGORA,  //zhaoxy add for angora  
    ]
}
//zhaoxy add for basic block coverage end

impl From<protos::FuzzerType> for FuzzerType {
    fn from(fuzzer_type: protos::FuzzerType) -> Self {
        match fuzzer_type {
            protos::FuzzerType::FUZZER_TYPE_UNSPECIFIED => FuzzerType::Unknown,
            protos::FuzzerType::FUZZER_TYPE_AFL => FuzzerType::AFL,
            protos::FuzzerType::FUZZER_TYPE_ANGORA => FuzzerType::ANGORA,  //zhaoxy add for angora
            protos::FuzzerType::FUZZER_TYPE_QSYM => FuzzerType::QSYM,
            protos::FuzzerType::FUZZER_TYPE_LIBFUZZER => FuzzerType::LIBFUZZER,
            protos::FuzzerType::FUZZER_TYPE_HONGGFUZZ => FuzzerType::HONGGFUZZ,
            protos::FuzzerType::FUZZER_TYPE_AFLFAST => FuzzerType::AFLFAST,
            protos::FuzzerType::FUZZER_TYPE_FAIRFUZZ => FuzzerType::FAIRFUZZ,
            protos::FuzzerType::FUZZER_TYPE_RADAMSA => FuzzerType::RADAMSA,
            protos::FuzzerType::FUZZER_TYPE_AFLPPZXY => FuzzerType::AFLPPZXY,
            protos::FuzzerType::FUZZER_TYPE_SYMCC => FuzzerType::SYMCC,  //zhaoxy add for symcc 
            protos::FuzzerType::FUZZER_TYPE_PARMESAN => FuzzerType::PARMESAN,  //zhaoxy add for PARMESAN 
            protos::FuzzerType::FUZZER_TYPE_AFLPLUSPLUS => FuzzerType::AFLPLUSPLUS,  //zhaoxy add for aflplusplus  
            protos::FuzzerType::FUZZER_TYPE_MOPT => FuzzerType::MOPT,  //zhaoxy add for aflplusplus               
        }
    }
}

impl fmt::Display for FuzzerType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            FuzzerType::Unknown => write!(f, "unknown"),
            FuzzerType::AFL => write!(f, "afl"),
            FuzzerType::ANGORA => write!(f, "angora"),  //zhaoxy add for angora
            FuzzerType::QSYM => write!(f, "qsym"),
            FuzzerType::LIBFUZZER => write!(f, "libfuzzer"),
            FuzzerType::HONGGFUZZ => write!(f, "honggfuzz"),
            FuzzerType::AFLFAST => write!(f, "aflfast"),
            FuzzerType::FAIRFUZZ => write!(f, "fairfuzz"),
            FuzzerType::RADAMSA => write!(f, "radamsa"),
            FuzzerType::AFLPPZXY => write!(f, "aflppzxy"), 
            FuzzerType::SYMCC => write!(f, "symcc"),  //zhaoxy add for symcc
            FuzzerType::PARMESAN => write!(f, "parmesan"),  //zhaoxy add for parmesan
            FuzzerType::AFLPLUSPLUS => write!(f, "aflplusplus"), //zhaoxy add for aflplusplus 
            FuzzerType::MOPT => write!(f, "mopt"), //zhaoxy add for aflplusplus      
        }
    }
}

#[derive(Default)]
pub struct FuzzersHandler {
    fuzzer_to_type: HashMap<FuzzerId, FuzzerType>,
    fuzzer_type_to_queue: HashMap<FuzzerType, VecDeque<FuzzerId>>,
}

impl FuzzersHandler {
    pub fn new() -> Self {
        FuzzersHandler {
            fuzzer_to_type: HashMap::new(),
            fuzzer_type_to_queue: HashMap::new(),
        }
    }

    fn get_unique_id(&self) -> FuzzerId {
        // This does not handle the case in which we have enough fuzzers to fill a u32, but that
        // should not happen.
        loop {
            let rand_val = random();

            // ID 0 is reserved for broadcast
            if rand_val == 0 {
                continue;
            }

            let new_id = FuzzerId(rand_val);
            if !self.fuzzer_to_type.contains_key(&new_id) {
                return new_id;
            }
        }
    }

    pub fn register_fuzzer(&mut self, fuzzer_type: FuzzerType) -> FuzzerId {
        let current_id = self.get_unique_id();
        self.fuzzer_to_type.insert(current_id, fuzzer_type);

        self.fuzzer_type_to_queue
            .entry(fuzzer_type)
            .or_insert_with(VecDeque::new);

        current_id
    }

    pub fn deregister_fuzzer(&mut self, fuzzer_id: FuzzerId) -> Option<FuzzerId> {
        let fuzzer_type = self.fuzzer_to_type.remove(&fuzzer_id)?;

        let type_queue = self
            .fuzzer_type_to_queue
            .get_mut(&fuzzer_type)
            .expect("Invalid type");

        let mut target_id = None;
        for (idx, queue_fuzzer_id) in type_queue.iter().enumerate() {
            if *queue_fuzzer_id == fuzzer_id {
                target_id = Some(idx);
            }
        }

        if let Some(target_id) = target_id {
            type_queue.remove(target_id);
        }

        Some(fuzzer_id)
    }

    pub fn mark_as_ready(&mut self, fuzzer_id: FuzzerId) -> Result<(), Box<dyn Error>> {
        let fuzzer_type = self
            .fuzzer_to_type
            .get(&fuzzer_id)
            .expect("Invalid fuzzer_id");
        let type_queue = self
            .fuzzer_type_to_queue
            .get_mut(fuzzer_type)
            .expect("Invalid type");
        if !type_queue.contains(&fuzzer_id) {
            type_queue.push_back(fuzzer_id);
            Ok(())
        } else {
            Err(Box::new(FuzzersHandlerError(String::from(
                "Fuzzer reported ready multiple times",
            ))))
        }
    }

    pub fn get_available_types(&self) -> Vec<FuzzerType> {
        let mut available_types = Vec::new();
        for (fuzzer_type, queue) in self.fuzzer_type_to_queue.iter() {
            if !queue.is_empty() {
                available_types.push(*fuzzer_type)
            }
        }

        available_types
    }

    pub fn schedule_all_fuzzers_with_type(
        &mut self,
        fuzzer_type: FuzzerType,
    ) -> VecDeque<FuzzerId> {
        mem::replace(
            self.fuzzer_type_to_queue
                .get_mut(&fuzzer_type)
                .expect("Invalid fuzzer type"),
            VecDeque::new(),
        )
    }

    pub fn schedule_fuzzer_with_type(&mut self, fuzzer_type: FuzzerType) -> FuzzerId {
        let mut type_queue = self
            .fuzzer_type_to_queue
            .remove(&fuzzer_type)
            .expect("Invalid fuzzer type");
        type_queue.pop_front().expect("Type not available")
    }

    pub fn get_fuzzer_type(&self, fuzzer_id: FuzzerId) -> Option<FuzzerType> {
        self.fuzzer_to_type.get(&fuzzer_id).cloned()
    }

    //zhaoxy add custom scheduler start
    pub fn get_available_types_edge(&self) -> Vec<FuzzerType> {
        let mut available_types = Vec::new();
        for (fuzzer_type, queue) in self.fuzzer_type_to_queue.iter() {
            if !queue.is_empty() && get_fuzzer_edge_types().contains(fuzzer_type) {
                available_types.push(*fuzzer_type)
            }
        }

        available_types
    }

    pub fn get_available_types_bb(&self) -> Vec<FuzzerType> {
        let mut available_types = Vec::new();
        for (fuzzer_type, queue) in self.fuzzer_type_to_queue.iter() {
            if !queue.is_empty() && get_fuzzer_bb_types().contains(fuzzer_type) {
                available_types.push(*fuzzer_type)
            }
        }

        available_types
    }

    pub fn get_available_types_other(&self) -> Vec<FuzzerType> {
        let mut available_types = Vec::new();
        for (fuzzer_type, queue) in self.fuzzer_type_to_queue.iter() {
            if !queue.is_empty() && get_fuzzer_other_types().contains(fuzzer_type) {
                available_types.push(*fuzzer_type)
            }
        }

        available_types
    }
    //zhaoxy add custom scheduler end

}
