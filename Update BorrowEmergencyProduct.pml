mtype = {search_product, send_request_to_retrive, processing_req, receive_product_info, check_availability_data, available, checkout_product, redirect_to_paysystem, not_available, stockout_product, try_another_product, click_on_borrow, in_stock};

chan toUser = [2] of {mtype,bit};
chan toSystem = [2] of {mtype,bit};
bool availablee = 1;


proctype User(chan in, out) 
{
    bit sendbit, recvbit;
    
    do
    ::out ! search_product, sendbit;
       in ? check_availability_data, recvbit;

    
    if
    :: availablee == 1 -> 
        in ? in_stock, recvbit; 
        out ! click_on_borrow, sendbit ->
        
        out ! checkout_product, sendbit ->
        in ? redirect_to_paysystem, recvbit;
    
    ::  availablee == 0 -> 
        out ! stockout_product, sendbit ->
        in ? try_another_product, recvbit;

    fi
    
    od
    
}

proctype System(chan in, out) 
{
    bit recvbit;
    
    do:: 

    in ? search_product(recvbit);
    out ! check_availability_data(recvbit);


    if
    :: availablee == 1 -> 
    out ! in_stock(recvbit);
    in ? click_on_borrow(recvbit);

    in ? checkout_product(recvbit) -> out ! redirect_to_paysystem(recvbit); 
	availablee = 0;
    :: availablee == 0 -> in ? stockout_product(recvbit) -> out ! try_another_product(recvbit); 
	availablee = 1;
    fi

    od
    
}

init
{
    run User(toUser, toSystem);
    run System(toSystem, toUser);
}
