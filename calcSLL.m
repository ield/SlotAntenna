function [sll] = calcSLL(y)
    % Function created tp find the sll. It is found the second maximum of
    % the function and it is returned its value
    peaks = findpeaks(y);
    maxLoc = find(peaks == max(peaks));
    peaks(maxLoc) = min(y);
    sll = max(y) - max(peaks);
end

