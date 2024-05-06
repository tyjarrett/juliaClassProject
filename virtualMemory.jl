using Gtk

win = GtkWindow("Virtual Memory Simulation", 1500, 1000)

g = GtkGrid()
t = GtkLabel("By: Ty Jarrett")
e = GtkLabel("")
b = GtkButton("Next")
s = GtkButton("Submit")
ent = GtkEntry()

step = [1]
miss = [0]
loc = [0]

function on_button_clicked(w)
    if(step[1] <= 9)
        i = demand_paging[step[1]]
        if(parse(Int, i) in main_memory)
            ls3[6, step[1]] = "hit"
        else
            ls3[6, step[1]] = "miss"
            miss[1] = miss[1] + 1
            if(length(main_memory) < 4)
                push!(main_memory, parse(Int, i))
            else
                main_memory[loc[1] + 1] = parse(Int, i) 
            end
            for i = 1:9
                if(i in main_memory)
                    ls2[i, 1] = true
                    ls[i, 1] = false
                else
                    ls[i, 1] = true
                    ls2[i, 1] = false
                end
            end
            loc[1] = (loc[1] + 1) % 4
        end
        for (index, value) in enumerate(main_memory)
            ls3[6-index, step[1]] = "$value"
        end
        step[1] += 1
        ls4[1,2] = "$(miss[1])"
    else
        d = GtkButton("Complete")
        g[x_size - 2, y_size] = d
    end
end


signal_connect(on_button_clicked, b, "clicked")




ls = GtkListStore(Bool, Int)
ls2 = GtkListStore(Bool, Int)
ls3 = GtkListStore(String, String, String, String, String, String, String, String, String)
ls4 = GtkListStore(Bool, String)

x_size = 10
y_size = 10

demand = "6 1 1 4 6 8 4 8 1"

virtual_memory = [1, 2, 3, 4, 5, 6, 7, 8, 9]
main_memory = []
demand_paging = split(demand, " ")

function on_button_clicked2(w)
    for i = 1:length(main_memory)
        popfirst!(main_memory)
    end
    step[1] = 1
    miss[1] = 0
    loc[1] = 0
    str = get_gtk_property(ent,:text,String)
    demand = str
    demand_pag = split(demand, " ")
    for i = 1:9
        virtual_memory[i] = i
        demand_paging[i] = demand_pag[i]
        ls3[1,i] = demand_paging[i]
        for ii = 2:6
            ls3[ii,i] = ""
        end
    end
    for i = 1:9
        if(i in main_memory)
            ls2[i, 1] = true
            ls[i, 1] = false
        else
            ls[i, 1] = true
            ls2[i, 1] = false
        end
    end
end

signal_connect(on_button_clicked2, s, "clicked")
 
for i = 1:9
    if(i in virtual_memory)
        push!(ls, (true, i))
    else 
        push!(ls, (false, i))
    end
end

for i = 1:9
    if(i in main_memory)
        push!(ls2, (true, i))
    else 
        push!(ls2, (false, i))
    end
end

push!(ls3, (demand_paging[1], demand_paging[2], demand_paging[3], demand_paging[4], demand_paging[5], demand_paging[6], demand_paging[7], demand_paging[8], demand_paging[9]))
push!(ls3, ("", "", "", "", "", "", "", "", ""))
push!(ls3, ("", "", "", "", "", "", "", "", ""))
push!(ls3, ("", "", "", "", "", "", "", "", ""))
push!(ls3, ("", "", "", "", "", "", "", "", ""))
push!(ls3, ("", "", "", "", "", "", "", "", ""))

push!(ls4, (true, ""))

rTxt = GtkCellRendererText()
c = GtkTreeViewColumn("Virtual Secondary Memory", rTxt, Dict([("text", 1)]))

c2 = GtkTreeViewColumn("Main Memory", rTxt, Dict([("text", 1)]))

c3 = GtkTreeViewColumn("", rTxt, Dict([("text", 0)]))
c4 = GtkTreeViewColumn("", rTxt, Dict([("text", 1)]))
c5 = GtkTreeViewColumn("", rTxt, Dict([("text", 2)]))
c6 = GtkTreeViewColumn("", rTxt, Dict([("text", 3)]))
c7 = GtkTreeViewColumn("", rTxt, Dict([("text", 4)]))
c8 = GtkTreeViewColumn("", rTxt, Dict([("text", 5)]))
c9 = GtkTreeViewColumn("", rTxt, Dict([("text", 6)]))
c10 = GtkTreeViewColumn("", rTxt, Dict([("text", 7)]))
c11 = GtkTreeViewColumn("", rTxt, Dict([("text", 8)]))

c12 = GtkTreeViewColumn("Miss Count", rTxt, Dict([("text", 1)]))

tmFiltered = GtkTreeModelFilter(ls)
GAccessor.visible_column(tmFiltered,0)
tv = GtkTreeView(GtkTreeModel(tmFiltered))

tmFiltered = GtkTreeModelFilter(ls)

tm2Filtered = GtkTreeModelFilter(ls2)
GAccessor.visible_column(tm2Filtered,0)
tv2 = GtkTreeView(GtkTreeModel(tm2Filtered))

tm2Filtered = GtkTreeModelFilter(ls2)

tv3 = GtkTreeView(GtkTreeModel(ls3))

tv4 = GtkTreeView(GtkTreeModel(ls4))

push!(tv, c)
push!(tv2, c2)
push!(tv3, c3, c4, c5, c6, c7, c8, c9, c10, c11)
push!(tv4, c12)



g[1:x_size, 1:y_size] = e
g[4,4] = tv
g[8,4] = tv2
g[4, 8] = tv3
g[x_size - 1, y_size] = tv4
g[x_size - 2, y_size] = b
g[9,9] = ent
g[10,9] = s

g[x_size, y_size] = t



set_gtk_property!(g, :column_spacing, 80)  # introduce a 15-pixel gap between columns

set_gtk_property!(g, :row_spacing, 50)
push!(win, g)
showall(win)
