function string.all_trim(s)
    return s:match"^%s*(.*)":match"(.-)%s*$"
end