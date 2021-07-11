mtype = {visit_website, login_req, check_validation, send_login_req, execution, receive_response, authenticate_info, login_success, redirect_to_homepage, valid_authentication_info, invalid_authentication_info, login_failed, wrong_info};
chan toUser = [2] of {mtype,bit};
chan toSystem = [2] of {mtype,bit};
bool valid = 1;
proctype User(chan in, out) 
{
    bit sendbit, recvbit;
    do
    :: 
        out ! visit_website, sendbit;
        out ! login_req, sendbit;
        in ? check_validation, recvbit;
        in ? authenticate_info, recvbit;
    if
    :: valid == 1 -> 
        out ! login_success, sendbit ->
        in ? redirect_to_homepage, recvbit;
    ::  valid == 0 -> 
        out ! login_failed, sendbit ->
        in ? wrong_info, recvbit;
    fi
    od
}
proctype System(chan in, out) 
{
    bit recvbit;
    do:: 
    in ? visit_website(recvbit);
    in ? login_req(recvbit);
    out ! check_validation(recvbit);
    out ! authenticate_info(recvbit);
    if
    :: valid == 1 -> in ? login_success(recvbit) -> out ! redirect_to_homepage(recvbit); valid = 0;
    :: valid == 0 -> in ? login_failed(recvbit) -> out ! wrong_info(recvbit); valid = 1;
    fi
    od
}

init
{
    run User(toUser, toSystem);
    run System(toSystem, toUser);
}
