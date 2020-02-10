local TableUtil = {}

--[[
    function ScriptAction:quickSortSeq(seq,left,right)
    local temp = seq[left].z ;
    local tempName = seq[left].name;
    local p = left;
    local i = p;
    local j = right;
    while i<=j do 
        while j>=p and seq[j].z  >= temp do 
            j = j - 1;
        end
        if j>= p then 
            seq[p].z  = seq[j].z ;
            seq[p].name  = seq[j].name;
            p = j;
        end
        while  i<= p  and  seq[i].z <=temp do 
            i = i + 1;
        end
        if i<=p then 
            seq[p].z  = seq[i].z ;
            seq[p].name  = seq[i].name;
            p = i;
        end
    end
    seq[p].z  = temp;
    seq[p].name = tempName;
    if p - left > 1 then 
        self:quickSortSeq(seq,left,p-1);
    end

    if right - p > 1 then 
        self:quickSortSeq(seq,p+1,right);
    end
    return seq;
end
]]--

TableUtil.QuickSort = function(seq,left,right,cb)
   
    local temp = cb(seq[left]) ;--seq[left].z ;
    local tempName = seq[left]; --seq[left].name;
    local p = left;
    local i = p;
    local j = right;
    while i<=j do 
        while j>=p and cb(seq[j]) >= temp do --seq[j].z  >= temp
            j = j - 1;
        end
        if j>= p then 
            --seq[p].z  = seq[j].z ;
            --seq[p].name  = seq[j].name;
            seq[p] = seq[j];
            p = j;
        end
        while  i<= p  and cb(seq[i])<=temp do -- seq[i].z <=temp
            i = i + 1;
        end
        if i<=p then 
            --seq[p].z  = seq[i].z ;
            --seq[p].name  = seq[i].name;
            seq[p]  = seq[i];
            p = i;
        end
    end
    --seq[p].z  = temp;
    --seq[p].name = tempName;
    seq[p] = tempName;
     if p - left > 1 then 
        TableUtil.QuickSort(seq,left,p-1,cb);
    end

    if right - p > 1 then 
        TableUtil.QuickSort(seq,p+1,right,cb);
    end--[[]]--
    return seq;
end


return TableUtil;