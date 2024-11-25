## Комп'ютерні системи імітаційного моделювання
## СПм-23-5, **Плугін Владислав В'ячеславович**
### Лабораторна робота №**2**. Редагування імітаційних моделей у середовищі NetLogo

breed [ muscle-cells muscle-cell ]

muscle-cells-own [
  cell-size   ;; Розмір клітини (аналогічно розміру волокна)
  max-cell-size ;; Максимальний розмір клітини
]

patches-own [
  growth-hormone    ;; Гормон росту
  decay-hormone     ;; Гормон розпаду
]

globals [
  total-muscle-mass  ;; Загальна маса м'язів
  growth-hormone-max ;; Максимальне значення гормону росту
  growth-hormone-min ;; Мінімальне значення гормону росту
  decay-hormone-max  ;; Максимальне значення гормону розпаду
  decay-hormone-min  ;; Мінімальне значення гормону розпаду
  hormone-diffusion-rate ;; Швидкість дифузії гормонів
]

to setup
  clear-all
  set-default-shape muscle-cells "circle"
  initialize-hormones
  create-muscle-cells
  set sleep-hours (sleep-hours - (sleep-hours / 100 * deviation-factor / 100 * deviation-chance))
  set recovery-days (recovery-days - (recovery-days / 100 * deviation-factor / 100 * deviation-chance))
  set training-effort (training-effort - (training-effort / 100 * deviation-factor / 100 * deviation-chance))
  set total-muscle-mass sum [cell-size] of muscle-cells
  reset-ticks
end

to initialize-hormones
  set hormone-diffusion-rate 0.75
  ask patches [
    set growth-hormone-max 200
    set decay-hormone-max 250
    set growth-hormone-min 50
    set decay-hormone-min 52
    set growth-hormone 50
    set decay-hormone 52
  ]
  regulate-hormones
end

to create-muscle-cells
  ask patches [
    sprout-muscle-cells 1 [
      set max-cell-size 4
      repeat 20 [
        if random-float 100 > slow-twitch-percentage [
          set max-cell-size max-cell-size + 1
        ]
      ]
      set cell-size (0.2 + random-float 0.4) * max-cell-size
      regulate-cell-size
    ]
  ]
end

to go
  daily-activities
  if lifting? and (ticks mod recovery-days = 0)
    [ perform-training ]
  simulate-sleep
  apply-genetics
  simulate-nutrition
  regulate-hormones
  grow-muscle
  set total-muscle-mass sum [cell-size] of muscle-cells
  tick
end

to daily-activities
  ask muscle-cells [
    set decay-hormone decay-hormone + 2.0 * (log cell-size 10)
    set growth-hormone growth-hormone + 2.5 * (log cell-size 10)
  ]
end

to perform-training
  ask muscle-cells [
    if (random-float 1.0 < training-effort) [
      set growth-hormone growth-hormone + (log cell-size 10) * 55
      set decay-hormone decay-hormone + (log cell-size 10) * 44
    ]
  ]
end

to simulate-nutrition
  ask patches [
    set decay-hormone decay-hormone - 0.6 * (log decay-hormone 10) * nutrition-quality
    set growth-hormone growth-hormone - 0.7 * (log growth-hormone 10) * nutrition-quality
  ]
end

to apply-genetics
  ask patches [
    set decay-hormone decay-hormone - 0.3 * genetic-factor
    set growth-hormone growth-hormone - 0.4 * genetic-factor
  ]
end

to simulate-sleep
  ask patches [
    set decay-hormone decay-hormone - 0.5 * (log decay-hormone 10) * sleep-hours
    set growth-hormone growth-hormone - 0.48 * (log growth-hormone 10) * sleep-hours
  ]
end

to grow-muscle
  ask muscle-cells [
    grow-cell
    regulate-cell-size
  ]
end

to grow-cell
  set cell-size (cell-size - 0.20 * (log decay-hormone 10))
  set cell-size (cell-size + 0.20 * min (list (log growth-hormone 10)
                                              (1.05 * log decay-hormone 10)))
end

to regulate-cell-size
  if (cell-size < 1) [ set cell-size 1 ]
  if (cell-size > max-cell-size) [ set cell-size max-cell-size ]
  set color scale-color red cell-size (-0.5 * max-cell-size) (3 * max-cell-size)
  set size max list 0.2 (min list 1 (cell-size / 20))
end

to regulate-hormones
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

