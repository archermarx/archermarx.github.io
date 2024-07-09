-- function Block(el)
--   print(el.t)
--   if el.t == "Para" or el.t == "Plain" or el.t == "Div" or el.T == "BulletList" or el.T == "RawBlock" then
--       for k, _ in ipairs(el.content) do
--         print(el.content[k].t)
--           -- print(el.content[k].text)
--           if el.content[k].t == "Str" or el.content[k].t == "RawInline" and el.content[k].text == "Marks," then
--           -- and
--           --     el.content[k + 1].t == "Space" and el.content[k + 2].t == "Str" and
--           --     el.content[k + 2].text:find("^T.") then

--               local _, e = el.content[k + 2].text:find("^T.")
--               local rest = el.content[k + 2].text:sub(e + 1) -- empty if e+1>length
--               el.content[k] = pandoc.Strong {pandoc.Str("Marks, T. A.")}
--               el.content[k + 1] = pandoc.Str(rest)
--               table.remove(el.content, k + 2) -- safe? another way would be to set element k+2 to Str("")
--               -- no real need to skip ipairs items here
--           end
--       end
--   end
--   return el
-- end

-- function Str(elem)
--   --print(elem.text)
--   if elem.text == "marksta_placeholder," then
--     return pandoc.Strong {pandoc.Str "Marks, T. A.,"}
--   elseif elem.text == "marksta_placeholder." then
--     return pandoc.Strong {pandoc.Str "Marks, T. A."}
--   else
--     return elem
--   end
-- end

function Inlines (inlines)
  local N = #inlines
  for i = 1, N do
    local inline = inlines[i]
    if (inline.t == "Str" and inline.text == "Marks,") then
      if i < N-4 and inlines[i+1].t == "Space" and 
        inlines[i+2].t == "Str" and inlines[i+2].text == "T." and
        inlines[i+3].t == "Space" and
        inlines[i+4].t == "Str" and inlines[i+4].text:sub(1,2) == "A." then

        remainder = inlines[i+4].text:sub(3,inlines[i+4].text:len())
        inlines[i] = pandoc.Strong {pandoc.Str "Marks, T. A."}

        for j = 1, 4 do
          inlines[i+j] = pandoc.Str("")
        end

        if remainder == "," then
          inlines[i+1] = pandoc.Str(",")
        end
        
      end
    elseif not (inline.t == "Str") then
      --print(inline)
    end
  end
  return inlines
end
