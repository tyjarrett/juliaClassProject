import Pkg
Pkg.add("Plots")

using Plots, CSV, DataFrames

#Let me know what yall think
#But I got a new idea for each of us
#to make a plot of this bitcoin data
#but each use a different package
#like the ones below
#PlotlyJS and Makie

function openDataset()
       
    DataFrame(CSV.File("bitcoin_2017_to_2023.csv"))

end

df = openDataset()

#esseantially just a bunch of functions to graph diffrent parts of the data
#run addOpenColor then graphOpenByDayWithColor to get color visuals

function printAdjustDateTime(df, length)
    output = [Dates.DateTime(2023, 8, 1, 13, 19, 0)]
    last = nrow(df)
    for i = 2:length
        push!(output, output[i-1] - Minute(1))
    end
    println(output)
end

function adjustDateTime(df)
    output = [Dates.DateTime(2023, 8, 1, 13, 19, 0)]
    last = nrow(df)
    for i = 2:last
        push!(output, output[i-1] - Minute(1))
    end
    insertcols!(df, 8, :Time => output)
end

function addOpenColor(df)
    output = [:green]
    start = nrow(df)
    for i = start-1:-1:1
        if(df[i,2] > df[i+1, 2])
            pushfirst!(output,:red)
        else
            pushfirst!(output,:green)
        end
    end
    insertcols!(df, 8, :Color => output)
end

function graphOpen(df, hours)
    start = nrow(df)
    plot(df[start:-1:start-hours, 1], df[start:-1:start-hours, 2])
end

function graphOpen(df, start, hours)
    start = nrow(df) - start
    plot(df[start:-1:start-hours, 1], df[start:-1:start-hours, 2])
end

function graphOpenTime(df)
    start = nrow(df)
    plot(map(x -> Date(x), df[start:-1:start-100, 9]), df[start:-1:start-100, 2])
end

function graphOpen(df)
    start = nrow(df)
    plot(df[start:-1:1, 1], df[start:-1:1, 2])
end

function  graphOpenByHour(df, hours)

    plot(df[1:60:hours*60, 1], df[1:60:hours*60, 2])
    
end

function  graphOpenByDay(df, days)

    plot(df[1:24*60:days*24*60, 1], df[1:24*60:days*24*60, 2])
    
end

function  graphOpenByDay(df, days, start)

    plot(df[start*24*60:24*60:days*24*60 + start*24*60, 1], df[start*24*60:24*60:days*24*60 + start*24*60, 2])
    
end

function printColumn(df)
    output = [:green]
    start = nrow(df)
    for i = start-1:-1:start-100
        if(df[i,2] < df[i+1, 2])
            pushfirst!(output,:red)
        else
            pushfirst!(output,:green)
        end
    end
    println(output)
end

function  graphOpenByDayWithColor(df, days)
    ref = true
    markercolor = [ :green
                    :red ]
    plot(df[1:days*24, 1], df[1:days*24, 2], color = df[1:days*24, 9])
end
