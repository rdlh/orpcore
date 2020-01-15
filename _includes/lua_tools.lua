-- Count in array
function count(array)
    local nb = 0

    for k,v in pairs(array) do
        nb = nb + 1
    end

    return nb
end