
theDirections = [2 2 5 5 2 4 3 5 3 3 2 3 4 5 4 4 2 2 5 5 2 4 3 5 3 3 2 3 4 5 4 4];

counter = zeros(5,2);
cfsOn = zeros(1,length(theDirections));
%static = 0
%CFS = 1
for k = 1:length(theDirections)
    if counter(theDirections(k),1) == 4 %already 4 static trials
        cfsOn(k) = 1;
        counter(theDirections(k),2) = counter(theDirections(k),2) + 1;
    elseif counter(theDirections(k),2) == 4  %already 4 CFS trials
        cfsOn(k) = 0;
        counter(theDirections(k),1) = counter(theDirections(k),1) + 1;
    elseif rand < .5 %make static
        cfsOn(k) = 0;
        counter(theDirections(k),1) = counter(theDirections(k),1) + 1;
    else %make CFS
        cfsOn(k) = 1;
        counter(theDirections(k),2) = counter(theDirections(k),2) + 1;
        
    end
end

cfsOn
        
