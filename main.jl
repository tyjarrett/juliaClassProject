import Pkg
Pkg.add("Plots")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("Polynomials")
Pkg.add("CairoMakie")

using Plots, CSV, DataFrames
using Polynomials
using CairoMakie
using Statistics

#Let me know what yall think
#But I got a new idea for each of us
#to make a plot of this bitcoin data
#but each use a different package
#like the ones below
#PlotlyJS and Makie

function openDataset()
    DataFrame(CSV.File("bitcoin_2017_to_2023.csv"))
end

function load_data(filepath)

    df = CSV.File(filepath) |> DataFrame

    base_time = nothing
    seconds_since_start = Float64[]

    for ts in df.timestamp
        year, month, day, hour, min, sec = parse(Int, ts[1:4]), parse(Int, ts[6:7]), parse(Int, ts[9:10]), parse(Int, ts[12:13]), parse(Int, ts[15:16]), parse(Int, ts[18:19])
        current_time = ((year * 365 + month * 30 + day) * 24 + hour) * 3600 + min * 60 + sec  

        if base_time === nothing
            base_time = current_time
        end

        push!(seconds_since_start, current_time - base_time)

    end

    df.seconds_since_start = seconds_since_start
    df.days_since_start = df.seconds_since_start / (24 * 3600)

    return df
end

function plot_data(df)
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], xlabel="Days since start", ylabel="Close Price", title="Bitcoin Close Price Over Time")
    lines!(ax, df.days_since_start, df.close, color=:blue, linewidth=2)
    display(fig)
end

function plot_volume(df)
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], xlabel="Days since start", ylabel="Volume", title="Bitcoin Trading Volume Over Time")
    lines!(ax, df.days_since_start, df.volume, color=:green, linewidth=2)
    display(fig)
end

# function plot_scatter_with_trend(df)
#     fig = Figure(size=(800, 600))
#     ax = Axis(fig[1, 1], xlabel="Days since start", ylabel="Price", title="Bitcoin Price Scatter with Trend")

#     scatterplot = Makie.scatter!(ax, df.days_since_start, df.high, color=:red, label="High Prices")

#     p = Makie.fit(df.days_since_start, df.high, 1) 

#     trendline_x = minimum(df.days_since_start):maximum(df.days_since_start)
#     trendline_y = p.(trendline_x)

#     trendline = lines!(ax, trendline_x, trendline_y, color=:blue, linewidth=2, label="Trend Line")

#     legend = Legend(fig[1, 2], [scatterplot, trendline], ["High Prices", "Trend Line"])
#     fig[1, 2] = legend
#     legend.backgroundcolor = (:white, 0.5)

#     display(fig)
# end
# #esseantially just a bunch of functions to graph diffrent parts of the data
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


df = openDataset()
df2 = load_data("bitcoin_2017_to_2023.csv")
addOpenColor(df)
display(graphOpenByDayWithColor(df, 10))
display(histogramOfPrices(df))
display(colorBar(df))
display(OHLCByDays(df, 1))
display(candlestickByDays(df, 1))
display(heatmapHighToLowByVolumeByDays(df, 1))
display(areaOfNumTradesToVolumeByDays(df, 100))
display(boxSomeVars(df, 100))
plot_data(df2)  
plot_volume(df2)  
# plot_scatter_with_trend(df2)
