mtype = {send_login_req, send_request, receive_response, authenticate_login, redirect_to_Admin_page, pending_product_list, perform_action_approve_or_reject_product, send_action_request, processing, receive_request_result, approve_pending_product, product_live, reject_product, delete_product_info};

chan toAdmin = [2] of {mtype,bit};
chan toSystem = [2] of {mtype,bit};
bool success = 1;


proctype Admin(chan in, out) 
{
    bit sendbit, recvbit;
    
    do
    :: out ! send_login_req, sendbit;
    in ?authenticate_login, recvbit;
    in ? redirect_to_Admin_page, recvbit;
    in ? pending_product_list, recvbit;
    out ! perform_action_approve_or_reject_product, sendbit;
    
    if
    :: success == 1 -> 
        out ! approve_pending_product, sendbit ->
        in ? product_live, recvbit;
    
    ::  success == 0 -> 
        out ! reject_product, sendbit ->
        in ? delete_product_info, recvbit;

    fi
    
    od
    
}

proctype System(chan in, out) 
{
    bit recvbit;
    
    do:: 

    in ? send_login_req(recvbit);
    out ! authenticate_login(recvbit);
    out ! redirect_to_Admin_page(recvbit);
    out ! pending_product_list(recvbit);
    in ? perform_action_approve_or_reject_product(recvbit);

    if
    :: success == 1 -> in ? approve_pending_product(recvbit) -> out ! product_live(recvbit); success = 0;
    :: success == 0 -> in ? reject_product(recvbit) -> out ! delete_product_info(recvbit); 
    success = 1;
    fi

    od
    
}

init
{
    run Admin(toAdmin, toSystem);
    run System(toSystem, toAdmin);
}
