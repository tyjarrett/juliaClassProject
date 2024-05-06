import Pkg
Pkg.add("Plots")
Pkg.add("CSV")
Pkg.add("DataFrames")

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
    Plots.plot(df[1:days*24, 1], df[1:days*24, 2], color = df[1:days*24, 9])
end

function histogramOfPrices(df)
    Plots.histogram(df[:, 2], bins=20, xlabel="Price (USD)", ylabel="Frequency", title="Histogram of Bitcoin Prices", fill=true)
end

Pkg.add("PlotlyJS")
using PlotlyJS
Pkg.add("StatsBase")
using StatsBase

function colorBar(df)
    cm = StatsBase.countmap(df.Color)
    data = PlotlyJS.bar(;x = collect(keys(cm)), y = collect(values(cm)))
    PlotlyJS.plot(data)
end

function OHLCByDays(df, days)
    PlotlyJS.plot(PlotlyJS.ohlc(open = df[1:days*24, "open"], high = df[1:days*24, "high"], low = df[1:days*24, "low"], close = df[1:days*24, "close"]))
end

function candlestickByDays(df, days)
    PlotlyJS.plot(PlotlyJS.candlestick(open = df[1:days*24, "open"], high = df[1:days*24, "high"], low = df[1:days*24, "low"], close = df[1:days*24, "close"]))
end

function heatmapHighToLowByVolumeByDays(df, days)
    PlotlyJS.plot(PlotlyJS.heatmap(x = df[1:days*24, "high"], y = df[1:days*24, "low"], z = df[1:days*24, "volume"]))
end

function areaOfNumTradesToVolumeByDays(df, days)
    s1 = PlotlyJS.scatter(; x = df[1:days*24, "timestamp"], y = df[1:days*24, "number_of_trades"], fill = "tonexty", name = "Number of Trades")
    s2 = PlotlyJS.scatter(; x = df[1:days*24, "timestamp"], y = df[1:days*24, "volume"], fill = "tozeroy", name = "Volume")
    PlotlyJS.plot([s1, s2], Layout(yaxis_range=[0, 1000]))
end

function boxSomeVars(df, days)
    t1 = PlotlyJS.box(; y = df[1:days*24, "open"], name = "Open")
    t2 = PlotlyJS.box(; y = df[1:days*24, "high"], name = "High")
    t3 = PlotlyJS.box(; y = df[1:days*24, "low"], name = "Low")
    t4 = PlotlyJS.box(; y = df[1:days*24, "close"], name = "Close")
    # t5 = PlotlyJS.box(; y = df[1:days*24, "volume"], name = "Volume")
    PlotlyJS.plot([t1, t2, t3, t4])
end

# main
df = openDataset()
addOpenColor(df)
display(graphOpenByDayWithColor(df, 10))
display(histogramOfPrices(df))
display(colorBar(df))
display(OHLCByDays(df, 1))
display(candlestickByDays(df, 1))
display(heatmapHighToLowByVolumeByDays(df, 1))
display(areaOfNumTradesToVolumeByDays(df, 100))
display(boxSomeVars(df, 100))