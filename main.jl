using Pkg
Pkg.add("Polynomials")

using Polynomials
using CairoMakie
using CSV
using DataFrames
using Statistics

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

# function plot_candlestick(df)
#     fig = Figure(size=(1000, 600))
#     ax = Axis(fig[1, 1], xlabel="Days since start", ylabel="Price", title="Bitcoin Candlestick Chart")

#     for i in 1:length(df.days_since_start)
#         day = df.days_since_start[i]
#         open, high, low, close = df.open[i], df.high[i], df.low[i], df.close[i]
         
#         lines!(ax, [day, day], [low, high], color=:black)

#         color = open > close ? :red : :green


#         rect_width = 0.2   
#         x_points = [day - rect_width / 2, day + rect_width / 2, day + rect_width / 2, day - rect_width / 2]
#         y_points = [min(open, close), min(open, close), max(open, close), max(open, close)]
#         vertices = [x_points[1] y_points[1];   
#                     x_points[2] y_points[2];
#                     x_points[3] y_points[3];
#                     x_points[4] y_points[4]]

#         lines!(ax, x_points, y_points, color=color, linewidth=1, close=true)
#         poly!(ax, vertices, color=color)
#     end

#     display(fig)
# end

function plot_scatter_with_trend(df)
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], xlabel="Days since start", ylabel="Price", title="Bitcoin Price Scatter with Trend")

    scatterplot = scatter!(ax, df.days_since_start, df.high, color=:red, label="High Prices")

    p = fit(df.days_since_start, df.high, 1) 

    trendline_x = minimum(df.days_since_start):maximum(df.days_since_start)
    trendline_y = p.(trendline_x)

    trendline = lines!(ax, trendline_x, trendline_y, color=:blue, linewidth=2, label="Trend Line")

    legend = Legend(fig[1, 2], [scatterplot, trendline], ["High Prices", "Trend Line"])
    fig[1, 2] = legend
    legend.backgroundcolor = (:white, 0.5)

    display(fig)
end

function main()
    df = load_data("bitcoin_2017_to_2023.csv")
    plot_data(df)  
    plot_volume(df)  
    # plot_candlestick(df)
    plot_scatter_with_trend(df)
end

main()
