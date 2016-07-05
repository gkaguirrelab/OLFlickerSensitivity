clear all;
close all;
%fclose(instrfindall);
macProIP = '192.168.2.2';

macProUDP = udp(macProIP, 2008, 'LocalPort', 2008);
fopen(macProUDP);

fprintf(macProUDP, '1');

sent = 0;
received = 0;
while true
    
    while macProUDP.BytesAvailable > 0
        fscanf(macProUDP);
        received = received + 1;
    end
    
    fprintf('Messages received: %d \n', received);
    
    fprintf(macProUDP, '1');
    sent = sent + 1;
    fprintf('Messages sent: %d \n', sent);
    
    pause(rand*5)
    
end