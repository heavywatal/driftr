# -*- coding: utf-8 -*-
library(shiny)
library(plyr)
library(dplyr)
library(pipeR)
library(ggplot2)

simulate = function(N, p, s, generations) {
    freq = p
    for (i in seq_len(generations - 1)) {
        p = rbinom(1, N, min((1 + s) * p, 1)) / N
        freq = c(freq, p)
    }
    data.frame(time=seq_len(generations), freq=freq)
}

dbinom_selection = function(x, size, prob, s=0) {
    choose(size, x) * (1 - prob)^(size - x) * ((1 + s) * prob)^x / (1 + s * prob)^size
}

distribution = function(N, i, s, generations) {
    prob = numeric(N + 1)
    prob[i+1] = 1
    x = seq(0, N)

    evolve = function() {
        sapply(x, function(.k) {
            sum(dbinom_selection(.k, N, x / N, s) * prob)
        })
    }

    env = environment()
    ldply(seq_len(generations), function(time) {
        assign('prob', evolve(), env=env)
        data.frame(time, freq=(seq_along(prob) - 1)/N, probability=prob) %>>%
            mutate(bin=cut(freq, breaks=23)) %>>%
            group_by(time, bin) %>>%
            summarize(freq=mean(freq), probability=sum(probability)) %>>%
            ungroup()
    }) %>>%
        mutate(timebin=cut(time, breaks=25)) %>>%
        group_by(timebin, freq) %>>%
        summarize(time=mean(time), probability=mean(probability))
}

locale = 'ja'
title_template = c(
    en='Evolutionary trajectories of %d replicates',
    ja='反復試行%d回分の軌跡')

shinyServer(function(input, output) {
  output$title = renderText({
      input$go
      sprintf(title_template[locale], isolate(input$replications))
  })
  output$lineplot <- renderPlot({
    input$go
    isolate({
        .data = rdply(input$replications,
                    simulate(input$popsize,
                        input$frequency,
                        input$selection,
                        input$generations))
        .p = ggplot(.data, aes(time, freq))
        if (input$predict) {
            .prob = distribution(input$popsize,
                        input$frequency * input$popsize,
                        input$selection,
                        input$generations)
            .p = .p + geom_tile(data=.prob, aes(time, freq, fill=sqrt(probability)))+
                      scale_fill_gradientn(colours=c('#FFFFFF', '#009999'))
        }
        .p = .p + geom_line(alpha=0.5, aes(group=.n))+
            theme_bw()+
            theme(panel.background=element_blank(), panel.grid=element_blank())+
            coord_cartesian(c(0, input$generations), c(0, 1))+
            labs(x='Time (generations)', y='Frequency')
        .p
    })
  })
})
