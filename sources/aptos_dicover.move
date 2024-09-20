module dapp::aptos_discover {

    use std;
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use aptos_std::smart_vector;
    use aptos_framework::account::{SignerCapability, create_resource_address, create_signer_with_capability};

    const Seed:vector<u8> = b"discover";

    ///Error  code
    const No_q_set:u64=1;
    const Not_exist_problem_set :u64 = 2;
    const No_this_image :u64 = 3;

    struct ResourceCap has key{
        cap:SignerCapability
    }
    ///owner of organiztion
    struct Organization has key{
        name:string::String,
        address:address,
        organization_discribe:string::String
    }
    ///problem want to soleve
    struct Problem has key {
        problem:string::String,
        owner_address:address,
        date:string::String
    }

    ///data which want to aptos community to mark
    struct Q_set has key {
        img_url_set : smart_vector::SmartVector<string::String>,
        true_number:u64,
        false_number:u64,
        answer_number:u64,
        reward:u64,
    }
    /// user answer data
    struct User_answer has key{
        image:string::String,
        index_of_smart_vector:u64,
        answer:bool,
        user_address:address,
        date:string::String,
    }
    /// store all data
    struct Problem_set has key {
        owner:Organization,
        problem_details:Problem,
        question:Q_set,
        true_answer:smart_vector::SmartVector<User_answer>,
        false_answer:smart_vector::SmartVector<User_answer>
    }

    /// for Organization


    public entry fun Create_Q_set (caller:&signer,image_vector:smart_vector::SmartVector<string::String>,reward_budget:u64){
        let new_q_set = Q_set{
            img_url_set:image_vector,
            true_number:0,
            false_number:0,
            answer_number:0,
            reward:reward_budget
        };
        move_to(caller,new_q_set);
    }

    public entry fun create_problem_set (caller:&signer,problem1:string::String,date1:string::String,descibe:string::String,name_of_Organization:string::String) acquires Q_set {
        let new_organ = Organization{
            name:name_of_Organization,
            address:address_of(caller),
            organization_discribe:descibe
        };
        assert!(exists<Q_set>(address_of(caller)),No_q_set);
        let q_set = move_from<Q_set>(address_of(caller));
        let new_Problem = Problem{
            problem:problem1,
            owner_address:address_of(caller),
            date:date1
        };
        let new_problem_set = Problem_set{
            owner:new_organ,
            problem_details:new_Problem,
            question:q_set,
            true_answer:smart_vector::empty<User_answer>(),
            false_answer:smart_vector::empty<User_answer>()
        };
        move_to(caller,new_problem_set);
    }

    /// for user

    public entry fun answer_question(caller:&signer,image_url:string::String,answer1:bool,data1:string::String,problem_set_address:address) acquires Problem_set {
        assert!(exists<Problem_set>(problem_set_address),Not_exist_problem_set);
        let index = find_index(problem_set_address,image_url);
        let borrow = borrow_global_mut<Problem_set>(problem_set_address);
        assert!(index != 9999999,No_this_image);
        let new_user_anser = User_answer{
            image:image_url,
            index_of_smart_vector:index,
            answer:answer1,
            user_address:address_of(caller),
            date:data1
        };
        if (answer1){
            smart_vector::push_back(&mut borrow.true_answer,new_user_anser);
            borrow.question.true_number=borrow.question.true_number+1;
            borrow.question.answer_number= borrow.question.answer_number+1;
        }else{
            smart_vector::push_back(&mut borrow.false_answer,new_user_anser);
            borrow.question.false_number=  borrow.question.false_number+1;
            borrow.question.answer_number= borrow.question.answer_number+1;
        }
    }

    ///logic

    fun find_index (caller:address,image_target:string::String):u64 acquires Problem_set {
        let length = smart_vector::length(&borrow_global<Problem_set>(caller).question.img_url_set);
        let index = 9999999;
        let  i= 0;
        while (i < length ){
            let borrow_target = smart_vector::borrow(&borrow_global<Problem_set>(caller).question.img_url_set,i);
            if(&image_target == borrow_target){
                index = i;
            };
            i = i+1;
        };
        return index
    }
    
    fun init_module() {

    }

}

