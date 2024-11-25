breed [ muscle-cells muscle-cell ]

muscle-cells-own [
  cell-size   ;; analogous to muscle fiber size
  max-size
]

patches-own [
  growth-hormone    ;; hormone promoting growth
  decay-hormone     ;; hormone causing degradation
]

globals [
  total-muscle-mass  ;; sum of all muscle cell sizes
  ;; hormone boundaries to simulate realistic conditions
  growth-hormone-max
  growth-hormone-min
  decay-hormone-max
  decay-hormone-min
  ;; diffusion rate for hormones between cells
  hormone-diffusion-rate
]

to setup
  clear-all
  set-default-shape muscle-cells "circle"
  initialize-hormones
  create-muscle-cells
  set sleep-hours (sleep-hours - (sleep-hours / 100 * variability-factor / 100 * probability-factor))
  set recovery-days (recovery-days - (recovery-days / 100 * variability-factor / 100 * probability-factor))
  set effort-level (effort-level - (effort-level / 100 * variability-factor / 100 * probability-factor))
  set total-muscle-mass sum [cell-size] of muscle-cells
  reset-ticks
end

to initialize-hormones
  ;; Set hormone limits and initialize hormone values for simulation
  set hormone-diffusion-rate 0.75
  ask patches [
    set growth-hormone-max 200
    set decay-hormone-max 250
    set growth-hormone-min 50
    set decay-hormone-min 52
    set growth-hormone 50
    set decay-hormone 52
  ]
  adjust-hormones
end

to create-muscle-cells
  ask patches [
    sprout-muscle-cells 1 [
      set max-size 4
      ;; Generate muscle cell size influenced by genetic composition
      repeat 20 [
        if random-float 100 > %-slow-twitch-cells [
          set max-size max-size + 1
        ]
      ]
      ;; Set initial cell size within a varied range
      set cell-size (0.2 + random-float 0.4) * max-size
      constrain-cell-size
    ]
  ]
end

to go
  daily-activities
  if lifting? and (ticks mod recovery-days = 0)
    [ perform-lifting ]
  rest
  genetic-impact
  proper-nutrition
  adjust-hormones
  muscle-growth
  set total-muscle-mass sum [cell-size] of muscle-cells
  tick
end

to daily-activities
  ;; Simulate hormonal effects of daily routines
  ask muscle-cells [
    set decay-hormone decay-hormone + 2.0 * (log cell-size 10)
    set growth-hormone growth-hormone + 2.5 * (log cell-size 10)
  ]
end

to perform-lifting
  ;; Simulate hormonal response to resistance training
  ask muscle-cells [
    if (random-float 1.0 < effort-level) [
      set growth-hormone growth-hormone + (log cell-size 10) * 55
      set decay-hormone decay-hormone + (log cell-size 10) * 44
    ]
  ]
end

to proper-nutrition
  ;; Adjust hormones based on diet quality
  ask patches [
    set decay-hormone decay-hormone - 0.6 * (log decay-hormone 10) * food-quality
    set growth-hormone growth-hormone - 0.7 * (log growth-hormone 10) * food-quality
  ]
end

to genetic-impact
  ;; Influence of genetic predisposition on hormones
  ask patches [
    set decay-hormone decay-hormone - 0.3 * (log decay-hormone 10) * genetic-trait
    set growth-hormone growth-hormone - 0.4 * (log growth-hormone 10) * genetic-trait
  ]
end

to rest
  ;; Hormonal effects during sleep
  ask patches [
    set decay-hormone decay-hormone - 0.5 * (log decay-hormone 10) * sleep-hours
    set growth-hormone growth-hormone - 0.48 * (log growth-hormone 10) * sleep-hours
  ]
end

to muscle-growth
  ask muscle-cells [
    expand
    constrain-cell-size
  ]
end

to expand ;; cell procedure
  ;; Simulate growth or reduction of muscle cells based on hormone levels
  set cell-size (cell-size - 0.20 * (log decay-hormone 10))
  set cell-size (cell-size + 0.20 * min (list (log growth-hormone 10)
                                              (1.05 * log decay-hormone 10)))
end

to constrain-cell-size ;; cell procedure
  ;; Ensure cell size remains within realistic boundaries
  if (cell-size < 1) [ set cell-size 1 ]
  if (cell-size > max-size) [ set cell-size max-size ]
  set color scale-color red cell-size (-0.5 * max-size) (3 * max-size)
  set size max list 0.2 (min list 1 (cell-size / 20))
end

to adjust-hormones ;; patch procedure
  ;; Distribute hormones across patches and regulate levels
  diffuse growth-hormone hormone-diffusion-rate
  diffuse decay-hormone hormone-diffusion-rate
  ask patches [
    set growth-hormone min (list growth-hormone growth-hormone-max)
    set growth-hormone max (list growth-hormone growth-hormone-min)
    set decay-hormone min (list decay-hormone decay-hormone-max)
    set decay-hormone max (list decay-hormone decay-hormone-min)
    set pcolor approximate-rgb ((decay-hormone / decay-hormone-max) * 255)
                   ((growth-hormone / growth-hormone-max) * 255)
                   0
  ]
end

