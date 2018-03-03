;------------------------------------------------------------------------------------------------------;
; DATE : 2018-02-22                                                                                    ;
; NAME : HANNAH LEE                                                                                    ;
; PROJECT : HANGNAE HYUNSANG NONMUN                                                                    ;
;------------------------------------------------------------------------------------------------------;
; 2018-02-14 : Revise price-expectation procedure, auction procedure, occupied?                        ;
; 2018-02-15 : which-occupied? mystery, price-expectation                                              ;
; 2018-02-16 : BalanceSheet, moving people, bank's maximization, auction complete                      ;                                                                                                      ;
; 2016-02-17 : Finalize                                                                                ;
;------------------------------------------------------------------------------------------------------;

extensions [profiler gis table matrix stats time sound]

breed [Banks Bank]
Banks-own [cash reserve equity lending_rate deposit_rate bancrupt die_tick BA_mode]

breed [IBCredits IBCredit]
IBCredits-own [lender borrower amount start_tick end_tick]

breed [households household]
households-own [
  age home-status own-house own-mortgage own-jeonsejing own-walsejing price_expectation auction_name auction_name2
  targethouse targethouse2 cash deposits silmul loan equity income spending home-x home-y individual-cash-ratio
  cash_wanted mode money_to_take_next taken_loan children loan_required actual_loan ind-demand fundamentalist
  bid where h-price j-price w-price w-price2 h-size myBank_dep myBank_loan extra-h how-many apt

  utility-best
]

breed [Fires Fire]
Fires-own [myBank]

breed[houses house]
Houses-own[h-price j-price w-price occupied? which-occupied? which-owner h-size pps]

breed [mortgages mortgage]
mortgages-own [which-owner which-house purchasePrice remain_tick remain_loan]

breed [jeonsejings jeonsejing]
jeonsejings-own [seibja jibjuin which-house purchasePrice waiting? waiting-time]

breed [walsejings walsejing]
walsejings-own [seibja jibjuin which-house purchasePrice]

Links-own [birth_tick]
patches-own [name]

globals [
  small_value this-year this-month seoul-dataset Dobong-gu Dongdaemun-gu Dongjak-gu Eunpyeong-gu Geumcheon-gu Guro-gu
  Gangbuk-gu Gangdong-gu  Gangnam-gu Gangseo-gu Gwanak-gu Gwangjin-gu Jongno-gu Jung-gu Jungnang-gu Mapo-gu Nowon-gu Seocho-gu
  Songpa-gu Seongdong-gu Seodaemun-gu Seongbuk-gu Yangcheon-gu Yeongdeungpo-gu Yongsan-gu

  u uu v vv w actions actions2 actions3 k ktau p_t p_t_previous u_t u_t_previous f_t f_t_previous weiner weiner_previous sigma_f
  ReservationPriceA Pricebid bidder bidders auctioneer auctioneers object objects evicted evicteds homeless
  TransactionVolume_house TransactionVolume_jeonse TransactionVolume_walse winner seller numbid choice choice2

  buy_m jeonse_m walse_m stay_m sell_m jeonse2_m walse2_m tau2 d1 d2

  ticks_to_highlight_agent  BA_entry_cash  BA_entry_reserve  BA_entry_Credits_toHH  BA_entry_Credits_toBA
  BA_entry_loans_fromBA  BA_entry_total  BA_entry_deposits  BA_entry_equity  BA_entry_cash_previous  BA_entry_reserve_previous
  BA_entry_Credits_toHH_previous  BA_entry_Credits_toBA_previous  BA_entry_loans_fromBA_previous
  BA_entry_total_previous  BA_entry_deposits_previous  BA_entry_equity_previous  HH_entry_cash  HH_entry_deposits HH_entry_silmul
  HH_entry_loan  HH_entry_total  HH_entry_equity  HH_entry_cash_previous  HH_entry_deposits_previous  HH_entry_silmul_previous
  HH_entry_loan_previous  HH_entry_total_previous  HH_entry_equity_previous  CB_entry_currency_previous CB_entry_dept_previous
  CB_entry_equity_previous BA_thinking_previous  HH_thinking_previous  HouseholdToShowBalance_previous  BankToShowBalance_previous
  M0  M1  Aggr_CreditsToHH  Sum_Interbank_Credits TransactionVolume TransactionVolume_timer

  maxBuyerValue minSellerCost utility-best-buy utility-best-sell

  average-house-price average-jeonse-price average-walse-price average-gangnam-price average-non-price house-price-25 house-price-75

  mememe daegisuyo
]

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                             setup                                                    ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to setup
  clear-all
  random-seed new-seed;;1220110 ;;new-seed
  reset-ticks
  profiler:reset
  profiler:start
  set-patch-size 11
;  let where_you_at user-input "office? home?"
  if where_you_at = "office" [set-current-directory "C:\\Users\\bok\\Desktop\\data"]
  if where_you_at = "home" [set-current-directory "C:\\Users\\Hannah Lee\\Desktop"]
  show (word "Welcome! Bienvenido a NetLogo "netlogo-version".")
  let year substring date-and-time 22 26
  let month substring date-and-time 19 20
  let day substring date-and-time 16 18
  let hour substring date-and-time 0 5
  let dt time:difference-between (time:create (word year"-0"month"-"day" "hour)) (time:create "2018-03-30 00:00") "days"
  let hr time:difference-between (time:create (word year"-0"month"-"day" "hour)) (time:create "2018-03-30 00:00") "hours" mod 24
  show (word floor dt" days " floor hr " hours are left.")
  build-bank
  map-the-patch
  read-household
  build-house
  assign-bank
  assign-mortgage
  fill-the-patch
;  build-exthouse
  set-parameters
;  ask households [setxy [pxcor] of one-of patches with [pcolor = 9] [pycor] of one-of patches with [pcolor = 9]]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                                go                                                    ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to total
  foreach ["data2.prn" "data3.prn" "data4.prn" "data5.prn""data6.prn" "data7.prn" "data8.prn" "data9.prn" "data10.prn"][?1 ->
   set data ?1
  repeat 10 [
  setup
  build-exthouse
;  while [ticks <= 23] [
  price-expectation
  value-iteration2
  tick
  fill-the-patch
  preparation
  update-demographic
  report-balance-sheet
  profiler:stop
  type profiler:report
;  ]
;  if where_you_at = "office"
;  [set-current-directory (word "C:\\Users\\bok\\Desktop\\result\\0"substring date-and-time 19 20 substring date-and-time 16 18)]
;  if where_you_at = "home"
;  [set-current-directory (word "C:\\Users\\Hannah Lee\\Desktop\\result\\0"substring date-and-time 19 20 substring date-and-time 16 18 "_")]
;   export-all-plots (word "plots_0"substring date-and-time 19 20 substring date-and-time 16 18 random-float 1.0 ".csv")
]
  ]
end

  ;--------------------------------------------go-------------------------------------------------;
to go
  tick
  update-demographic
  report-balance-sheet
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                             export                                                   ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to export
;  let where_you_at user-input "office? home?"
  if where_you_at = "office"
  [set-current-directory (word "C:\\Users\\bok\\Desktop\\result\\0"substring date-and-time 19 20 substring date-and-time 16 18)]
  if where_you_at = "home"
  [set-current-directory (word "C:\\Users\\Hannah Lee\\Desktop\\result\\0"substring date-and-time 19 20 substring date-and-time 16 18)]
  export-view (word "view_0"substring date-and-time 19 20 substring date-and-time 16 18".png")
  export-view user-new-file
  export-interface (word "interface_0"substring date-and-time 19 20 substring date-and-time 16 18".png")
  export-output (word "output_0"substring date-and-time 19 20 substring date-and-time 16 18 random-float 1.0 ".csv")
  export-all-plots (word "plots_0"substring date-and-time 19 20 substring date-and-time 16 18 random-float 1.0 ".csv")
;  export-world (word "world_0"substring date-and-time 19 20 substring date-and-time 16 18".csv")
end

to build-bank
  create-Banks 9
  ask Banks [set shape "house colonial" set size 2 set color gray + 3 set bancrupt false set hidden? false
             set cash 100000  ;set reserve 6.800E4
             ]
;  place-bank
  ask Bank 0 [setxy 11 11] ask Bank 1 [setxy 22 11] ask Bank 2 [setxy 33 11] ask Bank 3 [setxy 11 22]
  ask Bank 4 [setxy 22 22] ask Bank 5 [setxy 33 22] ask Bank 6 [setxy 11 33] ask Bank 7 [setxy 22 33]
  ask Bank 8 [setxy 33 33]
  let EmptyString "     "
  ask patch 6.5 42 [set plabel-color red
    if price = "h-price" [set plabel (word "[HOUSE PRICE]")]
    if price = "j-price" [set plabel (word "[JEONSE PRICE]")]
    if price = "w-price" [set plabel (word "[WALSE PRICE]")]
    if price = "pps" [set plabel (word "[PRICE PER SIZE]")]]
  ask patch 8.5 41 [set plabel-color red set plabel (word " - policy rate : "policy_rate" %"(substring EmptyString 0 (6 - length (word precision policy_rate 5))))]
  ask patch 5.5 40 [set plabel-color red set plabel (word " - LTV : "(substring EmptyString 0 (4 - length (word precision LTV 1))) LTV" %")]
  ask patch 6 39 [set plabel-color red let jungchaek "-"
    ifelse count houses with [not member? [name] of patch-here (list "Dobong-gu" "Dongdaemun-gu" "Dongjak-gu" "Eunpyeong-gu" "Geumcheon-gu" "Guro-gu" "Gangbuk-gu" "Gangdong-gu" "Gangnam-gu"
                                                                     "Gangseo-gu" "Gwanak-gu" "Gwangjin-gu" "Jongno-gu" "Jung-gu" "Jungnang-gu" "Mapo-gu" "Nowon-gu" "Seocho-gu" "Songpa-gu"
                                                                     "Seongdong-gu" "Seodaemun-gu" "Seongbuk-gu" "Yangcheon-gu" "Yeongdeungpo-gu" "Yongsan-gu")] > 0 [set jungchaek "YES"][set jungchaek "NO"]
    set plabel (word " - supply? : "jungchaek (substring EmptyString 0 (2 - length (word jungchaek))))]
;   ask patch 41.5 38 [set plabel-color gray + 4 set plabel (word "RUNNING")]
end

;------------------------------------------------------------------------------------------------------;
;                                          map-the-patch                                               ;
;------------------------------------------------------------------------------------------------------;
to map-the-patch
  ifelse file-exists? "seoul.prj" and file-exists? "seoul.shp" and file-exists? "seoul.dbf" [
  gis:load-coordinate-system "seoul.prj"
  set seoul-dataset gis:load-dataset "seoul.shp"
  gis:set-coverage-minimum-threshold 0.1
  gis:set-coverage-maximum-threshold 0.33
  gis:set-world-envelope gis:envelope-of seoul-dataset
  gis:set-drawing-color gray - 3
  gis:draw seoul-dataset 0.5
  gis:apply-coverage seoul-dataset "SIG_ENG_NM" name
  set Dobong-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Dobong-gu"
  set Dongdaemun-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Dongdaemun-gu"
  set Dongjak-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Dongjak-gu"
  set Eunpyeong-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Eunpyeong-gu"
  set Geumcheon-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Geumcheon-gu"
  set Guro-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Guro-gu"
  set Gangbuk-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Gangbuk-gu"
  set Gangdong-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Gangdong-gu"
  set Gangnam-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Gangnam-gu"
  set Gangseo-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Gangseo-gu"
  set Gwanak-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Gwanak-gu"
  set Gwangjin-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Gwangjin-gu"
  set Jongno-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Jongno-gu"
  set Jung-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Jung-gu"
  set Jungnang-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Jungnang-gu"
  set Mapo-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Mapo-gu"
  set Nowon-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Nowon-gu"
  set Seocho-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Seocho-gu"
  set Songpa-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Songpa-gu"
  set Seongdong-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Seongdong-gu"
  set Seodaemun-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Seodaemun-gu"
  set Seongbuk-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Seongbuk-gu"
  set Yangcheon-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Yangcheon-gu"
  set Yeongdeungpo-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Yeongdeungpo-gu"
  set Yongsan-gu gis:find-one-feature seoul-dataset "SIG_ENG_NM" "Yongsan-gu"
  ][user-message "There's no file"]
  ask patches with [pycor > 6 and pycor <= 36] [set pcolor gray + 4]
  ask patches with [pycor <= 6 or pycor > 36] [set pcolor gray + 3]
end

;------------------------------------------------------------------------------------------------------;
;                                          read-household                                              ;
;------------------------------------------------------------------------------------------------------;
to read-household
  ifelse file-exists? data [
  file-open data
  while [not file-at-end?] [
    create-households 1 [
      set where file-read set apt file-read set home-status file-read set extra-h file-read set how-many file-read
      set h-price file-read  set j-price file-read set w-price file-read set h-size file-read  set age file-read
      set income file-read set spending file-read  set silmul file-read set deposits file-read set loan file-read
      ]
    ask households [set shape "person" set size 1.5 set color black
     if placement = "random" [ ;total 3697 households
  ;-----------------------------------------random-----------------------------------------------;
      if where = "Dobong-gu" [move-to one-of (patches gis:intersecting Dobong-gu)]
      if where = "Dongdaemun-gu" [move-to one-of (patches gis:intersecting Dongdaemun-gu)]
      if where = "Dongjak-gu" [move-to one-of (patches gis:intersecting Dongjak-gu)]
      if where = "Eunpyeong-gu" [move-to one-of (patches gis:intersecting Eunpyeong-gu)]
      if where = "Geumcheon-gu" [move-to one-of (patches gis:intersecting Geumcheon-gu)]
      if where = "Guro-gu" [move-to one-of (patches gis:intersecting guro-gu)]
      if where = "Gangbuk-gu" [move-to one-of (patches gis:intersecting Gangbuk-gu)]
      if where = "Gangdong-gu" [move-to one-of (patches gis:intersecting Gangdong-gu)]
      if where = "Gangnam-gu" [move-to one-of (patches gis:intersecting Gangnam-gu)]
      if where = "Gangseo-gu" [move-to one-of (patches gis:intersecting Gangseo-gu)]
      if where = "Gwanak-gu" [move-to one-of (patches gis:intersecting Gwanak-gu)]
      if where = "Gwangjin-gu" [move-to one-of (patches gis:intersecting Gwangjin-gu)]
      if where = "Jongno-gu" [move-to one-of (patches gis:intersecting Jongno-gu)]
      if where = "Jung-gu" [move-to one-of (patches gis:intersecting Jung-gu)]
      if where = "Jungnang-gu" [move-to one-of (patches gis:intersecting Jungnang-gu)]
      if where = "Mapo-gu" [move-to one-of (patches gis:intersecting Mapo-gu)]
      if where = "Nowon-gu" [move-to one-of (patches gis:intersecting Nowon-gu)]
      if where = "Seocho-gu" [move-to one-of (patches gis:intersecting Seocho-gu)]
      if where = "Songpa-gu" [move-to one-of (patches gis:intersecting Songpa-gu)]
      if where = "Seongdong-gu" [move-to one-of (patches gis:intersecting Seongdong-gu)]
      if where = "Seodaemun-gu" [move-to one-of (patches gis:intersecting Seodaemun-gu)]
      if where = "Seongbuk-gu" [move-to one-of (patches gis:intersecting Seongbuk-gu)]
      if where = "Yangcheon-gu" [move-to one-of (patches gis:intersecting Yangcheon-gu)]
      if where = "Yeongdeungpo-gu" [move-to one-of (patches gis:intersecting Yeongdeungpo-gu)]
      if where = "Yongsan-gu" [move-to one-of (patches gis:intersecting Yongsan-gu)]
      ]
     if placement = "center"[ ;representative 25 households
  ;-----------------------------------------center-----------------------------------------------;
      if where = "Dobong-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Dobong-gu) item 1 gis:location-of (gis:centroid-of Dobong-gu)]
      if where = "Dongdaemun-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Dongdaemun-gu) item 1 gis:location-of (gis:centroid-of Dongdaemun-gu)]
      if where = "Dongjak-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Dongjak-gu) item 1 gis:location-of (gis:centroid-of Dongjak-gu)]
      if where = "Eunpyeong-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Eunpyeong-gu) item 1 gis:location-of (gis:centroid-of Eunpyeong-gu)]
      if where = "Geumcheon-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Geumcheon-gu) item 1 gis:location-of (gis:centroid-of Geumcheon-gu)]
      if where = "Guro-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Guro-gu) item 1 gis:location-of (gis:centroid-of Guro-gu)]
      if where = "Gangbuk-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Gangbuk-gu) item 1 gis:location-of (gis:centroid-of Gangbuk-gu)]
      if where = "Gangdong-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Gangdong-gu) item 1 gis:location-of (gis:centroid-of Gangdong-gu)]
      if where = "Gangnam-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Gangnam-gu) item 1 gis:location-of (gis:centroid-of Gangnam-gu)]
      if where = "Gangseo-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Gangseo-gu) item 1 gis:location-of (gis:centroid-of Gangseo-gu)]
      if where = "Gwanak-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Gwanak-gu) item 1 gis:location-of (gis:centroid-of Gwanak-gu)]
      if where = "Gwangjin-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Gwangjin-gu) item 1 gis:location-of (gis:centroid-of Gwangjin-gu)]
      if where = "Jongno-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Jongno-gu) item 1 gis:location-of (gis:centroid-of Jongno-gu)]
      if where = "Jung-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Jung-gu) item 1 gis:location-of (gis:centroid-of Jung-gu)]
      if where = "Jungnang-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Jungnang-gu) item 1 gis:location-of (gis:centroid-of Jungnang-gu)]
      if where = "Mapo-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Mapo-gu) item 1 gis:location-of (gis:centroid-of Mapo-gu)]
      if where = "Nowon-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Nowon-gu) item 1 gis:location-of (gis:centroid-of Nowon-gu)]
      if where = "Seocho-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Seocho-gu) item 1 gis:location-of (gis:centroid-of Seocho-gu)]
      if where = "Songpa-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Songpa-gu) item 1 gis:location-of (gis:centroid-of Songpa-gu)]
      if where = "Seongdong-gu" [move-to patch item 0 gis:location-of (gis:centroid-of  Seongdong-gu) item 1 gis:location-of (gis:centroid-of Seongdong-gu)]
      if where = "Seongbuk-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Seongbuk-gu) item 1 gis:location-of (gis:centroid-of Seongbuk-gu)]
      if where = "Seodaemun-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Seodaemun-gu) item 1 gis:location-of (gis:centroid-of Seodaemun-gu)]
      if where = "Yangcheon-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Yangcheon-gu) item 1 gis:location-of (gis:centroid-of Yangcheon-gu)]
      if where = "Yeongdeungpo-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Yeongdeungpo-gu) item 1 gis:location-of (gis:centroid-of Yeongdeungpo-gu)]
      if where = "Yongsan-gu" [move-to patch item 0 gis:location-of (gis:centroid-of Yongsan-gu) item 1 gis:location-of (gis:centroid-of Yongsan-gu)]
      ]
      set home-x [pxcor] of patch-here  set home-y [pycor] of patch-here
      set targethouse nobody set targethouse2 nobody set children turtle-set nobody
      if home-status = 1 [set home-status "jaga"]
      if home-status = 2 [set home-status "jeonse"]
      if home-status = 4 [set home-status "walse"]
     ]
  ]
  file-close
  stop
  show "finished reading agent file"
  ][user-message "There's no file"]
end

to build-house
  ask households [hatch-houses 1]
  ask houses [set size 1.5  set color pink + 2 set shape "house"  set hidden? false]
  ask houses [
  ;-----------------------------------------prices----------------------------------------------;
;    set h-price precision random-gamma 2.0394 6.7770e-05 0
;    set j-price precision random-gamma 0.7988 4.1558e-05 0
;    set w-price precision random-gamma 0.2378 0.008554386 0
    set h-price precision random-gamma 0.75644454 2.118404e-05 0
    set j-price precision random-gamma 0.2328684 7.662487e-06 0
    set w-price precision random-normal 50 10 0
;    set h-price precision random-normal 75000 5000 0
;    set j-price precision random-normal (0.7 * 75000) 3000 0
;    set w-price precision random-normal 50 10 0

    if [h-price] of one-of households-here > 0 [set h-price [h-price] of one-of households-here]
    if [j-price] of one-of households-here > 0 [set j-price [j-price] of one-of households-here]
    if [w-price] of one-of households-here > 0 [set w-price [w-price] of one-of households-here]
  ;-----------------------------------------sizes------------------------------------------------;
    set h-size [h-size] of one-of households-here]
  foreach sort-on [who] houses [?1 ->
  ;------------------------------------ which-occupied?------------------------------------------;
     let occupier [households-here] of ?1
     set occupier occupier with [member? self making-electorate]
     ask ?1 [set which-occupied? one-of occupier
             set occupied? count occupier > 0]
  ;---------------------------------------which-owner--------------------------------------------;
    ifelse [home-status] of occupier = "jaga" [ask ?1 [set which-owner occupier]]
;                                              [ask ?1 [set which-owner one-of households with [extra-h = 1]]]]
                                              [ask ?1 [set which-owner one-of households]]]
  foreach sort-on [who] households [?2 ->
  ;----------------------------------------own-house---------------------------------------------;
    ask ?2 [if [home-status] of ?2 = "jaga" [set own-house houses-here]]
    ask ?2 [if [home-status] of ?2 = "jeonse" or [home-status] of ?2 = "walse" [set own-house houses with [which-owner = ?2]]]

  set w stats:newtable
  foreach [h-price] of houses [?1 ->
    stats:add w (list ?1)]
  stats:set-names w (list "house-price")

    ask households [set targethouse one-of houses-here set targethouse2 one-of houses-here]
    calculate-average-price
    calculate-percentile-price
    price-per-size
  ]
end

to assign-bank
  ask Households [
    let NumberOfBanks (count Banks)
    set myBank_dep random NumberOfBanks
    ifelse true [
      set myBank_dep random count Banks
      set myBank_loan myBank_dep + 1 + (random (count Banks - 1))
      if myBank_loan >= count Banks [set myBank_loan myBank_loan - count Banks]
      if myBank_dep = myBank_loan [user-message (word "Error: myBank_dep = myBank_loan,  Bank No.: " myBank_dep)]
    ] [
      let prob_loan n-values (count Banks) [0]
      let prob_dep n-values (count Banks) [0]
      let Counter 0
      while [Counter < count Banks] [  ; a loop through all banks
        set prob_loan replace-item Counter prob_loan (count Households with [myBank_loan = Counter])
        set prob_dep replace-item Counter prob_dep (count Households with [myBank_dep = Counter])
        set Counter Counter + 1
      ]
      set myBank_loan position (min prob_loan) prob_loan
      set myBank_dep position (min prob_dep) prob_dep
      if myBank_loan = myBank_dep [
        set myBank_dep myBank_dep + 1
        if myBank_dep >= count Banks [
          set myBank_dep myBank_dep - count Banks
        ]
      ]
    ]
  ]
end

to assign-mortgage
  ask households with [home-status = "jaga"][hatch-mortgages 1]
    ask mortgages [
      set size 1.5
      set color gray + 4
      set shape "hexagonal prism"
      set which-owner one-of households-here
      set which-house one-of houses-here
      set purchasePrice [h-price] of which-house
      set remain_tick random 180
      set remain_loan random-float 1 * purchasePrice]

  ask households with [home-status = "jeonse"][hatch-jeonsejings 1]
    ask jeonsejings [
      set size 1.5
      set color sky + 4
      set shape "hexagonal prism"
      set seibja one-of households-here
      set which-house one-of houses-here
      set jibjuin [which-owner] of which-house
      set purchasePrice [j-price] of which-house
      set waiting? true
      set waiting-time random 24]

  ask households with [home-status = "walse"][hatch-walsejings 1]
    ask walsejings [
      set size 1.5
      set color pink + 4
      set shape "hexagonal prism"
      set seibja one-of households-here
      set which-house one-of houses-here
      set jibjuin [which-owner] of which-house
      set purchasePrice [w-price] of which-house]

  ask households [set own-mortgage one-of mortgages-here]
  ask households [set own-jeonsejing one-of jeonsejings-here]
  ask households [set own-walsejing one-of walsejings-here]

  place-mortgage
  place-jeonsejing
  place-walsejing
end

to build-exthouse
  create-houses 20[set label "NEW" set label-color violet - 1]
  ask houses with [label = "NEW"] [
    set shape "house" set size 1.5 set color pink + 2 set h-size 24
    place-exhouse
    set h-price mean [pps] of houses with [h-price != 0] * h-size
    set j-price 0.7 * h-price
    set w-price mean [w-price] of houses with [w-price != 0]
  ;--------------------------------------distribution--------------------------------------------;
    set which-owner one-of households
    set which-occupied? turtle-set nobody
    set occupied? false]
  foreach sort-on [who] households [?2 ->
  ;----------------------------------------own-house---------------------------------------------;
    ask ?2 [if [home-status] of ?2 = "jaga" [set own-house houses-here]]
    ask ?2 [if [home-status] of ?2 = "jeonse" or [home-status] of ?2 = "walse" [set own-house houses with [which-owner = ?2]]]]
end

to set-parameters
  set tau2 25
  set u table:make
  set uu table:make
  set v matrix:make-constant 1000 5 0
  set vv matrix:make-constant tau2 7 0

  matrix:set-column v 0 (n-values 1000 [x -> x])
  matrix:set-column vv 0 (n-values tau2 [x -> x])
  set actions ["buy" "jeonse" "walse"]
  set actions2 ["sell" "jeonse" "walse"]
  set actions3 n-values 300 [x -> 0.01 * x]
  ask households [set fundamentalist false]
  ask turtle-set n-of (round (fundamental_ratio / 100) * count making-electorate) making-electorate [set fundamentalist true]
  set homeless turtle-set nobody
  set small_value 0.001
  set this-year  read-from-string substring date-and-time 22 26
  let months (list "JAN" "FEB" "MAR" "APR" "MAY" "JUN" "JUL" "AUG" "SEP" "OCT" "NOV" "DEC")
  set this-month item ((read-from-string substring date-and-time 19 20) - 1) months
  set BA_entry_cash_previous -1
  set k 0.001
  set ktau -1 * k * tau
  set p_t mean [h-price] of houses with [h-price != 0]
  set p_t_previous precision random-gamma 0.75644454 2.118404e-05 0
  set f_t_previous precision random-gamma 0.75644454 2.118404e-05 0
  set u_t_previous precision random-gamma 0.75644454 2.118404e-05 0
;  set p_t_previous 75000
;  set f_t_previous 75000
;  set u_t_previous 75000
  set sigma_f 0.01
  set weiner 0
  set f_t 2 * f_t_previous / (2 - sigma_f ^ 2 - sigma_f * weiner)
  set daegisuyo nobody
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                         price-expectation                                            ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to price-expectation
  show "expecting future house price by fundamentalists and speculators"
  foreach sort-on [who] households [?1 ->
  if ticks > 0 [
   set p_t_previous matrix:get v (ticks - 1) 1
   set u_t_previous matrix:get v (ticks - 1) 2
   set f_t_previous matrix:get v (ticks - 1) 3
   set weiner_previous matrix:get v (ticks - 1) 4
    ]

   set u_t max (list (u_t_previous / (1 + k) + (k / (1 + k) / (1 + -1 * (e ^ ktau)))  * (p_t + -1 * (e ^ ktau) * p_t_previous)) 30000)
   set weiner weiner + random-normal 0 1
   set f_t max (list (2 * f_t_previous / (2 - sigma_f ^ 2 - sigma_f * weiner)) 30000)

  put-v

  ;------------------------------------------question--------------------------------------------;
    ask ?1 [if fundamentalist = true [set price_expectation f_t]]  ;;f_t ;;stats:quantile w "house-price" 50
  ;------------------------------------------question--------------------------------------------;
    ask ?1 [if fundamentalist = false [set price_expectation u_t]]  ;;u_t
  ;------------------------------------------question--------------------------------------------;
    ]
end

to put-v
  if (ticks >= 1) or (ticks < tau + 1) [matrix:set v ticks 1 (mean [h-price] of houses with [h-price != 0])]
  if (ticks >= tau + 1) [
    let elements []
    foreach n-values (tau - 1) [x -> x][?1 ->
      let element_tmp matrix:get v (ticks - ?1) 1
      set elements fput element_tmp elements]
    matrix:set v ticks 1 precision (mean elements) 2
  ]
  matrix:set v ticks 2 precision u_t 2
  matrix:set v ticks 3 precision f_t 2
  matrix:set v ticks 4 precision weiner 2
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                          value-iteration                                             ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
  ;--------------------------------------get-best-action-----------------------------------------;
to-report get-best-action [x y]
  let best-action 0
  let best-utility 0
  if choice2 = "buyer" [
    set best-utility max (list buy x y jeonse x y walse x y)
    if precision (buy x y) 0 = precision best-utility 0 [set best-action "buy"]
    if precision (jeonse x y) 0 = precision best-utility 0 [set best-action "jeonse"]
    if precision (walse x y) 0 = precision best-utility 0 [set best-action "walse"]
    if not item 0 receiver y [set best-action "stay"]
  ]

  if choice2 = "seller" [
    set best-utility max (list sell x y jeonse2 x y walse2 x y)
    if precision (sell x y) 0 = precision best-utility 0 [set best-action "sell"]
    if precision (jeonse2 x y) 0 = precision best-utility 0 [set best-action "jeonse"]
    if precision (walse2 x y) 0 = precision best-utility 0 [set best-action "walse"]
  ]
  report (list best-action best-utility)
end

to put-utility [whom dir action utility]
  let state (list whom dir action)
  table:put u state utility
end

to-report house-on-market
  let house_on_market turtle-set nobody
  foreach sort-on [who] making-electorate with [count making-whoofhouse self > 0] [?1 ->
    let house_on_market_tmp making-whoofhouse ?1
    set house_on_market (turtle-set house_on_market_tmp house_on_market)]
  report house_on_market
end
to-report real-search [x]
  let real_search turtle-set nobody
  set real_search turtle-set (min-n-of 2 house-on-market [distance x]) with [not member? self turtle-set gohyang x]
;  set real_search turtle-set house-on-market with [not member? self turtle-set gohyang x]
  report real_search
end

  ;-------------------------------------------main---------------------------------------------;
to value-iteration [x]
if choice2 = "buyer" [
show "maxmimizing buyer's utility and deciding what to buy"]
if choice2 = "seller" [
show "maximizing seller's utility and deciding what to sell"]

if choice2 = "buyer" [
  set u table:make
    ifelse count house-on-market >= 2 [
      foreach sort-on [who] real-search x [?1 ->
        ask x [
          let best-utility item 1 get-best-action ?1 x
          let best-action item 0 get-best-action ?1 x
          if best-action = "buy" [
          let new-utility get-reward ?1 + gamma * best-utility
          put-utility [who] of x [who] of ?1 best-action new-utility]
          if best-action = "jeonse" or best-action = "walse" [
          let new-utility gamma * best-utility
          put-utility [who] of x [who] of ?1 best-action new-utility]
          if best-action = "stay" [
          let new-utility best-utility ;get-reward patch home-x home-y + gamma * best-utility
          put-utility [who] of x [who] of ?1 best-action new-utility]
        ]
      ]
    ]
      [total]
    midium x
]
if choice2 = "seller"[
   set u table:make
     foreach sort-on [who] [own-house] of x [?1 ->
        ask x [
          let best-utility item 1 get-best-action ?1 x
          let best-action item 0 get-best-action ?1 x
          let new-utility get-reward ?1 + gamma * best-utility
          put-utility [who] of x [who] of ?1 best-action new-utility
        ]
      ]
     midium x
 ]
end

to midium [x]
  let address 0
  let targethousedir 0
  let best-action 0
  let num length table:values u
  ifelse num = 0 [total][
  let util max table:values u
     foreach table:to-list u [?1 ->
     if item 1 ?1 = util [
      set address position ?1 table:to-list u
      set targethousedir item 1 item 0 item address table:to-list u
      set best-action item 2 item 0 item address table:to-list u]]
  if choice2 = "buyer" [
    if best-action = "buy" [ask x [set auction_name "buyer"]]
    if best-action = "jeonse" [ask x [set auction_name "jeonse"]]
    if best-action = "walse" [ask x [set auction_name "walse"]]
    if best-action = "stay" [ask x [set auction_name "stay"]]
    ask x [set targethouse house targethousedir]
    ask x [set utility-best-buy util]]
  if choice2 = "seller" [
    if best-action = "sell" [ask x [set auction_name2 "seller"]]
    if best-action = "jeonse" [ask x [set auction_name2 "jeonse"]]
    if best-action = "walse" [ask x [set auction_name2 "walse"]]
    ask x [set targethouse2 house targethousedir]
    ask x [set utility-best-sell util]]
  ]
 end

;------------------------------------------------------------------------------------------------------;
;                                      value-iteration's delicate                                      ;
;------------------------------------------------------------------------------------------------------;
to-report put-vv [x y]
  foreach n-values tau2 [i -> i] [?1 ->
  if ?1 = 0 [
  ;-------------------------------------------buy--------------------------------------------;
      let buy_m_tmp item 1 call-put x y 0 - [h-price] of x +
      ifelse-value ([name] of [patch-here] of x = "Gangnam-gu" or
                    [name] of [patch-here] of x = "Seocho-gu" or
                    [name] of [patch-here] of x = "Songpa-gu") [100000][0] + 100000
;     set buy_m_tmp item 1 call-put x y 0

  ;------------------------------------------jeonse------------------------------------------;
      let jeonse_m_tmp item 1 call-put x y 24 - [j-price] of x

  ;-------------------------------------------walse------------------------------------------;
      let walse_m_tmp -1 * [w-price] of x

  ;-------------------------------------------sell-------------------------------------------;
      let sell_m_tmp item 0 call-put x y 0 + [h-price] of x

  ;----------------------------------------sell-jeonse---------------------------------------;
      let jeonse2_m_tmp item 0 call-put x y 24 + [j-price] of x

  ;----------------------------------------sell-walse----------------------------------------;
      let walse2_m_tmp [w-price] of x

      matrix:set vv ?1 1 precision buy_m_tmp 2
      matrix:set vv ?1 2 precision jeonse_m_tmp 2
      matrix:set vv ?1 3 precision walse_m_tmp 2
      matrix:set vv ?1 4 precision sell_m_tmp 2
      matrix:set vv ?1 5 precision jeonse2_m_tmp 2
      matrix:set vv ?1 6 precision walse2_m_tmp 2
    ]
  if ?1 >= 1 and ?1 <= tau2 [
  ;-------------------------------------------buy--------------------------------------------;
      let buy_m_tmp -1 * [deposit_rate] of bank [myBank_dep] of y * [h-price] of x + item 1 call-put x y (tau2 - ?1)
       + ifelse-value ([name] of [patch-here] of x = "Gangnam-gu" or
                       [name] of [patch-here] of x = "Seocho-gu" or
                       [name] of [patch-here] of x = "Songpa-gu") [100000][0]
  ;------------------------------------------jeonse------------------------------------------;
      let jeonse_m_tmp -1 * [deposit_rate] of bank [myBank_dep] of y * [j-price] of x + item 1 call-put x y (24 - ?1)

  ;-------------------------------------------walse------------------------------------------;
      let walse_m_tmp -1 * [deposit_rate] of bank [myBank_dep] of y * [w-price] of x

  ;-------------------------------------------sell-------------------------------------------;
      let sell_m_tmp [deposit_rate] of bank [myBank_dep] of y * [h-price] of x + item 0 call-put x y (tau2 - ?1)

  ;----------------------------------------sell-jeonse---------------------------------------;
      let jeonse2_m_tmp [deposit_rate] of bank [myBank_dep] of y * [j-price] of x + item 0 call-put x y (24 - ?1)

  ;----------------------------------------sell-walse----------------------------------------;
      let walse2_m_tmp [deposit_rate] of bank [myBank_dep] of y  * [w-price] of x

      matrix:set vv ?1 1 precision buy_m_tmp 2
      matrix:set vv ?1 2 precision jeonse_m_tmp 2
      matrix:set vv ?1 3 precision walse_m_tmp 2
      matrix:set vv ?1 4 precision sell_m_tmp 2
      matrix:set vv ?1 5 precision jeonse2_m_tmp 2
      matrix:set vv ?1 6 precision walse2_m_tmp 2
    ]
  ]

  let elements []
  let bigelement_tmp 0
  let bigelements []
  foreach n-values 6 [j -> j][?1 ->
   foreach n-values tau2 [m -> m][?2 ->
      let element_tmp (gamma ^ ?2) * (matrix:get vv ?2 (?1 + 1))
      set elements lput element_tmp elements
  set bigelement_tmp mean elements]
  set bigelements lput bigelement_tmp bigelements]
  report bigelements
end

to-report call-put [x y z]
  ;----------------------------------------question--------------------------------------------;
  let S u_t
  if [fundamentalist] of y [set S f_t] ;;mean [h-price] of houses with [h-price != 0]
  ;----------------------------------------question--------------------------------------------;
  let rtt -1 * policy_rate * (tau2 - z)
  let sigma 5000
  set d1 ((ln (S / ([h-price] of x + small_value))) + (policy_rate + sigma / 2) * (tau2 - z)) / (sigma * sqrt (tau2 - z))
  set d2 d1 - (sigma * sqrt (tau2 - z))
  let call_value S * (stats:normal-left d1 0 1) - [h-price] of x * e ^ precision (rtt * stats:normal-left d2 0 1) 3
  let put_value S * (stats:normal-left d1 0 1) + [h-price] of x * e ^ precision (rtt * stats:normal-left d2 0 1) 3
  report (list call_value put_value)
end


to-report buy [x y]
  report precision (item 0 put-vv x y ) 0
end

to-report jeonse [x y]
  report precision (item 1 put-vv x y) 0
end

to-report walse [x y]
  report precision (item 2 put-vv x y) 0
end

to-report sell [x y]
  report precision (item 3 put-vv x y) 0
end

to-report jeonse2 [x y]
   report precision (item 4 put-vv x y) 0
end

to-report walse2 [x y]
  report precision (item 5 put-vv x y) 0
end

to-report get-reward [x]
  let reward 0
;  if x != nobody[
;    ask x [if [name] of patch-here = "Gangnam-gu" or [name] of patch-here = "Seocho-gu" or [name] of patch-here = "Songpa-gu" or
;      [name] of patch-here = "Gangdong-gu" [set reward 100000]]]
  report reward
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                          value-iteration2                                            ;
;                                        -bank's optimization-                                         ;
;------------------------------------------------------------------------------------------------------;
to put-utility2 [action demand utility]
  let state (list action demand)
  table:put uu state utility
end

  ;-------------------------------------------main---------------------------------------------;
to value-iteration2
show "maximizing bank's profit and deciding lending interest rate"
foreach sort-on [who] banks with [bancrupt = false] [?1 ->
   foreach actions3 [?2 ->
     let best-action 0
     let best-demand 0
     let deposit-demand 0
     let lending_rate_tmp policy_rate + ?2
     let deposit_rate_tmp policy_rate + (interest_margin / 100) * ?2
      foreach sort-on [who] loaning-house ?1 [?3 ->
        ask ?3 [set ind-demand ifelse-value ((?2 / 1200 * [h-price] of [targethouse] of ?3) < [income] of ?3 - [spending] of ?3) [[h-price] of [targethouse] of ?3][0]]]
        set best-demand sum [loan] of loaning-house ?1 + sum [ind-demand] of loaning-house ?1
        set deposit-demand sum [deposits] of depositing-house ?1
        let best-utility lending_rate_tmp * best-demand - deposit_rate_tmp * deposit-demand
        put-utility2 ?2 best-demand best-utility
    ]
    ask ?1 [midium2]
    ]
end

to midium2
  let address 0
  let targethousedir 0
  let best-action 0
  let num length table:values uu
  let util max table:values uu
     foreach table:to-list uu [?1 ->
     if item 1 ?1 = util [
      set address position ?1 table:to-list uu
      set best-action item 0 item 0 item address table:to-list uu]]
  set lending_rate policy_rate + best-action
  set deposit_rate policy_rate + (interest_margin / 100) * best-action
end

;------------------------------------------------------------------------------------------------------;
;                                      value-iteration's delicate                                      ;
;------------------------------------------------------------------------------------------------------;
to-report loaning-house [x]
  let lists sort-on [who] making-electorate with [myBank_loan = [who] of x]
  report turtle-set lists
end

to-report depositing-house [x]
  let lists sort-on [who] making-electorate with [myBank_dep = [who] of x]
  report turtle-set lists
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                         setup-auction                                                ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to setup-auction [x]
  show (word "setting up " [auction_name] of one-of households with [targethouse = x] " market now...")
   set numbid 0
   set bidder turtle-set nobody
   set auctioneer turtle-set nobody
   ;-----------------------------------bidder&auctioneer----------------------------------------;
   if choice = "buyer" [
      set bidder (turtle-set households with [targethouse = x and auction_name = "buyer"]
                             daegisuyo
;                             making-electorate with [auction_name = "buyer"]
;                             making-electorate with [[waiting?] of jeonsejings with [seibja = self] = false]
;                             making-electorate with [home-status = "walse"] homeless
    )
;      set auctioneer turtle-set z with [auction_name2 = "seller"]
      set auctioneer turtle-set [which-owner] of x
;      ask auctioneer [set color orange]
   ]

   if choice = "jeonse" [
      set bidder (turtle-set households with [targethouse = x and auction_name = "jeonse"]
                             daegisuyo
;                             making-electorate with [auction_name = "jeonse"]
;                             making-electorate with [[waiting?] of jeonsejings with [seibja = self] = false]
;                             making-electorate with [home-status = "walse"] homeless
    )
;      set auctioneer (turtle-set z with [auction_name2 = "seller"] households with [color = orange])
      set auctioneer (turtle-set [which-owner] of x) ; households with [color = orange])
;      ask auctioneer [set color orange + 1]
  ]

   if choice = "walse" [
       set bidder (turtle-set households with [targethouse = x and auction_name = "walse"]
                              daegisuyo
;                              making-electorate with [auction_name = "walse"]
;                              making-electorate with [[waiting?] of jeonsejings with [seibja = self] = false]
;                              making-electorate with [home-status = "walse"]
    )
;       set auctioneer (turtle-set z with [auction_name2 = "walse"] households with [color = orange + 1])
       set auctioneer (turtle-set [which-owner] of x) ;households with [color = orange + 1])
;       ask auctioneer [set color black]
  ]


    set bidder bidder with [not member? self auctioneer]
;    set auctioneer auctioneer with [not member? self bidder]

  ;-------------------------------------tmp_vacant---------------------------------------------;
  foreach sort-on [who] bidder [?1 ->
    let tmp_vacant one-of houses with [which-occupied? = ?1]
    if tmp_vacant != nobody [
      ask tmp_vacant [set occupied? false]]]

  ;---------------------------------------object-----------------------------------------------;
   if choice = "buyer" [
      set object nobody
      foreach sort-on [who] auctioneer [?1 ->
      set object (turtle-set (making-whoofhouse ?1) object)]
    if object != nobody [
      ask object [set label "SALE" set label-color violet - 1 set color violet + 3]]]

   if choice = "jeonse" [
      set object nobody
      foreach sort-on [who] auctioneer [?1 ->
      set object (turtle-set (making-whoofhouse ?1) object)]
    if object != nobody [
      ask x [set label "SALE" set label-color violet - 1 set color violet + 3]]]

   if choice = "walse" [
      set object nobody
      foreach sort-on [who] auctioneer [?1 ->
      set object (turtle-set (making-whoofhouse ?1) object)]
    if object != nobody [
      ask x [set label "SALE" set label-color violet - 1 set color violet + 3]]]

  ;---------------------------------------evicted----------------------------------------------;
    set evicted turtle-set nobody
    if count evicted != 0 [
    foreach sort-on [who] object [?1 ->
     foreach sort-on [who] making-electorate [?2 ->
        if [which-occupied?] of ?1 = ?2 and [which-owner] of ?1 != ?2 [
          set evicted (turtle-set ?2 evicted)]]]]
    set evicted evicted with [not member? self (turtle-set bidder auctioneer)]

;   place-auctioneer
;   place-bidder
;   place-evicted

; user-message (word "Congrates! House " [who] of x " trade is placed."
;     "                                                              "
;    "Bidder is Household " [who] of bidder" and Auctioneer is Household " [who] of one-of auctioneer".")
end

;------------------------------------------------------------------------------------------------------;
;                                                auction                                               ;
;------------------------------------------------------------------------------------------------------;
to auction [x]
 show (word "implementing " choice " market now... Trial " numbid)
 set homeless sort-on [who](turtle-set bidder auctioneer evicted)
 ifelse (count bidder != 0 and count auctioneer != 0 and count object != 0) [
    let thishouse one-of object
    if thishouse != nobody [
      set winner (item 0 make-bid-auction thishouse)
      set seller (item 1 make-bid-auction thishouse)
    ifelse winner != nobody and seller != nobody [
      win-result (turtle-set thishouse) winner seller
      set object object with [not member? self turtle-set thishouse]
      set bidder bidder with [not member? self turtle-set winner]
    ][
      set numbid numbid + 1
      price-adjustment
      if numbid > max_numbid [
        set bidder turtle-set nobody
        set auctioneer turtle-set nobody]]]]
    [
    if choice = "walse" [go-home]
    ]
end

;------------------------------------------------------------------------------------------------------;
;                                         make-bid-auction                                             ;
;------------------------------------------------------------------------------------------------------;
to-report make-bid-auction [x]

  ask houses [
;    set maxBuyerValue (random-gamma 6.666783 0.00613855) * [h-size] of x
;    set minSellerCost (random-gamma 6.666783 0.05333426) * [h-size] of x
;     set maxBuyerValue (random-gamma 0.311095 0.0002514759) * [h-size] of x
     set maxBuyerValue max [pps] of houses in-radius 20 * [h-size] of x
    ]

  ;----------------------------------------bid--------------------------------------------;
    if numbid = 0 [
    if choice = "buyer"[
      ask bidder [
;        let ReservationPriceB min utility-best (list (LTV / 100 * [h-price] of x + cash) maxBuyerValue)
;        let ReservationPriceB max (list min (list utility-best-buy (cash + LTV / 100 * [h-price] of x)) maxBuyerValue)
         let ReservationPriceB min (list utility-best-buy  maxBuyerValue)
         set bid min (list ReservationPriceB (cash + LTV / 100 * [h-price] of x)) + random-normal 0 1 set label precision bid -3 set label-color blue]]
    if choice = "jeonse"[
      ask bidder [
;        let ReservationPriceB min(list (LTV / 100 * [j-price] of x + cash) maxBuyerValue)
         let ReservationPriceB min (list utility-best-buy (0.9 * [h-price] of x))
         set bid ReservationPriceB + random-normal 0 1 set label precision bid -3 set label-color blue]]
    if choice = "walse" [
      ask bidder [
;         let ReservationPriceB max (list [w-price] of x)
          let ReservationPriceB min (list [w-price] of x ([j-price] of x / 24))
         set bid ReservationPriceB + random-normal 0 1 set label precision bid -3 set label-color blue]]

  ;------------------------------------ReservationPrice------------------------------------;
;    set seller one-of (turtle-set((turtle-set z) with [targethouse2 = x]) nobody)
;    set seller auctioneer with [member? self turtle-set [which-owner] of x]
    set seller [which-owner] of x
    if seller != nobody [
    ask seller [
    let neighborhouse turtle-set nobody
    if [name] of [patch-here] of x = "Dobong-gu" [set neighborhouse houses-on (patches gis:intersecting Dobong-gu)]
    if [name] of [patch-here] of x = "Dongdaemun-gu" [set neighborhouse houses-on (patches gis:intersecting Dongdaemun-gu)]
    if [name] of [patch-here] of x = "Dongjak-gu" [set neighborhouse houses-on (patches gis:intersecting Dongjak-gu)]
    if [name] of [patch-here] of x = "Eunpyeong-gu" [set neighborhouse houses-on (patches gis:intersecting Eunpyeong-gu)]
    if [name] of [patch-here] of x = "Geumcheon-gu" [set neighborhouse houses-on (patches gis:intersecting Geumcheon-gu)]
    if [name] of [patch-here] of x = "Guro-gu" [set neighborhouse houses-on (patches gis:intersecting Guro-gu)]
    if [name] of [patch-here] of x = "Gangbuk-gu" [set neighborhouse houses-on (patches gis:intersecting Gangbuk-gu)]
    if [name] of [patch-here] of x = "Gangdong-gu" [set neighborhouse houses-on (patches gis:intersecting Gangdong-gu)]
    if [name] of [patch-here] of x = "Gangnam-gu" [set neighborhouse houses-on (patches gis:intersecting Gangnam-gu)]
    if [name] of [patch-here] of x = "Gangseo-gu" [set neighborhouse houses-on (patches gis:intersecting Gangseo-gu)]
    if [name] of [patch-here] of x = "Gwanak-gu" [set neighborhouse houses-on (patches gis:intersecting Gwanak-gu)]
    if [name] of [patch-here] of x = "Gwangjin-gu" [set neighborhouse houses-on (patches gis:intersecting Gwangjin-gu)]
    if [name] of [patch-here] of x = "Jongno-gu" [set neighborhouse houses-on (patches gis:intersecting Jongno-gu)]
    if [name] of [patch-here] of x = "Jung-gu" [set neighborhouse houses-on (patches gis:intersecting Jung-gu)]
    if [name] of [patch-here] of x = "Jungnang-gu" [set neighborhouse houses-on (patches gis:intersecting Jungnang-gu)]
    if [name] of [patch-here] of x = "Mapo-gu" [set neighborhouse houses-on (patches gis:intersecting Mapo-gu)]
    if [name] of [patch-here] of x = "Nowon-gu" [set neighborhouse houses-on (patches gis:intersecting Nowon-gu)]
    if [name] of [patch-here] of x = "Seocho-gu" [set neighborhouse houses-on (patches gis:intersecting Seocho-gu)]
    if [name] of [patch-here] of x = "Songpa-gu" [set neighborhouse houses-on (patches gis:intersecting Songpa-gu)]
    if [name] of [patch-here] of x = "Seongdong-gu" [set neighborhouse houses-on (patches gis:intersecting Seongdong-gu)]
    if [name] of [patch-here] of x = "Seodaemun-gu" [set neighborhouse houses-on (patches gis:intersecting Seodaemun-gu)]
    if [name] of [patch-here] of x = "Seongbuk-gu" [set neighborhouse houses-on (patches gis:intersecting Seongbuk-gu)]
    if [name] of [patch-here] of x = "Yangcheon-gu" [set neighborhouse houses-on (patches gis:intersecting Yangcheon-gu)]
    if [name] of [patch-here] of x = "Yeongdeungpo-gu" [set neighborhouse houses-on (patches gis:intersecting Yeongdeungpo-gu)]
    if [name] of [patch-here] of x = "Yongsan-gu" [set neighborhouse houses-on (patches gis:intersecting Yongsan-gu)]

;    if choice = "auction" [set ReservationPriceA max (list [h-price] of neighborhouse with [h-price != 0] maxBuyerValue)]
;    if choice = "jeonse" [set ReservationPriceA max (list [j-price] of neighborhouse with [j-price != 0] maxBuyerValue)]
;    if choice = "walse" [set ReservationPriceA max (list [w-price] of neighborhouse with [w-price != 0] maxBuyerValue)]

;    if choice = "auction" [set ReservationPriceA max (list mean [h-price] of houses in-radius 20  maxBuyerValue)]
;    if choice = "jeonse" [set ReservationPriceA max (list mean [j-price] of houses in-radius 20  maxBuyerValue)]
;    if choice = "walse" [set ReservationPriceA max (list mean [w-price] of houses in-radius 20  maxBuyerValue)]

    if choice = "buyer"[
        set ReservationPriceA utility-best-sell]

    if choice = "jeonse"[
        set ReservationPriceA utility-best-sell]

    if choice = "walse"[
        set ReservationPriceA utility-best-sell]
      ]
    ]





  ]

  ;---------------------------------------adjustment-------------------------------------;
    if numbid > 0 [
    if choice = "buyer" [
      if seller = nobody [
        ask bidder [
          set bid 1.02 * bid
         ;set bid bid + 5000
          set label bid]]
      if winner = nobody [
        set ReservationPriceA 0.98 * ReservationPriceA
       ;set ReservationPriceA ReservationPriceA - 5000
    ]]

    if choice = "jeonse" [
      if seller = nobody [
        ask bidder [
          set bid 1.02 * bid
         ;set bid bid + 1000
          set label bid]]
      if winner = nobody [
        set ReservationPriceA 0.98 * ReservationPriceA
       ;set ReservationPriceA ReservationPriceA - 1000
    ]]

    if choice = "walse" [
      if seller = nobody [
        ask bidder [
          set bid 1.02 * bid
         ;set bid bid + 10
          set label bid]]
      if winner = nobody [
        set ReservationPriceA 0.98 * ReservationPriceA
       ;set ReservationPriceA ReservationPriceA - 10
    ]]
    ]

  ;------------------------------------------check---------------------------------------;
;    set winner turtle-set y with [bid = max [bid] of y and bid > ReservationPriceA]
;    if [bid] of y > ReservationPriceA [set winner turtle-set y]
    set winner bidder with [bid = max [bid] of bidder and bid > ReservationPriceA]
    if count winner = 1 [set numbid 0 set Pricebid item 0 [bid] of winner]
    if count winner > 1 [set seller nobody]
    if count winner = 0 [set winner nobody]
report (list winner seller)
end

;------------------------------------------------------------------------------------------------------;
;                                             win-result                                               ;
;------------------------------------------------------------------------------------------------------;
to win-result [x y z]
;  sound:play-note (item 0 sound:instruments) 60 128 2
  set z [which-owner] of one-of x
  ;-----------------------------------------volume----------------------------------------;
   if [auction_name] of one-of y = "buyer" [
    set TransactionVolume_house TransactionVolume_house + 1
;    user-message (word "Congrates! House " [who] of one-of x " trade has been settled."
;     "                                            "
;     "Buyer is Household " [who] of one-of y" and Seller is Household " [who] of z"."
;     "                                            "
;     "Contract Price is "precision [bid] of one-of y 0" man won, in " [name] of one-of [patch-here] of x".")
    ]
   if [auction_name] of one-of y = "jeonse" [
    set TransactionVolume_jeonse TransactionVolume_jeonse + 1
;    user-message (word "Congrates! Jeonse house " [who] of one-of x " contract has been settled."
;     "                                      "
;     "Buyer is Household "precision [who] of one-of y 0" and Seller is Household " [who] of z"."
;     "                                      "
;     "Contract Price is "precision [bid] of one-of y 0" man won, in " [name] of one-of [patch-here] of x".")
    ]
   if [auction_name] of one-of y = "walse" [
    set TransactionVolume_walse TransactionVolume_walse + 1
;   user-message (word "Congrates! Walse house " [who] of one-of x " contract has been settled."
;    "                                      "
;    "Buyer is Household "[who] of one-of y" and Seller is Household " [who] of z"."
;    "                                      "
;    "Contract Price is "precision [bid] of one-of y 0" man won, in " [name] of one-of [patch-here] of x".")
    ]

  ;------------------------------------------buyer----------------------------------------;
   if choice = "buyer" [
   ask y [set own-house (turtle-set x own-house) set home-status "jaga"
          hatch-mortgages 1 [
        set size 1.5
        set color gray + 4
        set shape "hexagonal prism"
        set which-owner one-of y
        set which-house one-of x
        set purchasePrice Pricebid
        set remain_tick 180
        set remain_loan purchasePrice
        set label ""
        place-mortgage]
        set own-mortgage mortgages with [which-owner = y]
  ]]

   if choice = "jeonse" [
   ask y [set home-status "jeonse"
          hatch-jeonsejings 1 [
        set size 1.5
        set color sky + 4
        set shape "hexagonal prism"
        set seibja one-of y
        set which-house one-of x
        set jibjuin z
        set purchasePrice Pricebid
        set waiting? true
        set waiting-time 24
        set label ""
        place-jeonsejing]
       set own-jeonsejing jeonsejings with [seibja = y]
  ]]

   if choice = "walse" [
   ask one-of y [set home-status "walse"
          hatch-walsejings 1 [
        set size 1.5
        set color pink + 4
        set shape "hexagonal prism"
        set seibja one-of y
        set which-house one-of x
        set jibjuin z
        set purchasePrice Pricebid
        set label ""
        place-walsejing]
        set own-walsejing walsejings with [seibja = y]
  ]]

   ;-----------------------------------------seller----------------------------------------;
    if choice = "buyer" [
    ask z [set own-house own-house with [not member? self x]]]


 ask y [
        let from_cash cash
        let from_deposits min (list deposits (Pricebid - from_cash))
        let from_loan Pricebid - from_cash - from_deposits
        set cash cash - from_cash
        set deposits deposits - from_deposits + from_loan
        set silmul silmul + Pricebid
        set loan loan + from_loan

        set cash_wanted individual-cash-ratio / (1 + individual-cash-ratio) * (Pricebid + spending + mortgage-payment one-of y + item 1 giver y - item 1 receiver y - interest-earnings one-of y - income + cash + deposits + silmul)
        set label ""
        if cash < cash_wanted - small_value [
        set mode 1
        set color red]
        if cash > cash_wanted + small_value [
        set mode 2
        set color green]
  ]

 ask z [;move-to gohyang self
        set cash cash + Pricebid
        set silmul silmul - Pricebid
        set label ""

        set cash_wanted individual-cash-ratio / (1 + individual-cash-ratio) * (spending + mortgage-payment one-of y + item 1 giver y - item 1 receiver y - interest-earnings one-of y - income - Pricebid + cash + deposits + silmul)
        if cash < cash_wanted - small_value [
        set mode 1
        set color red]
        if cash > cash_wanted + small_value [
        set mode 2
        set color green]
  ]

  ;------------------------------------------house----------------------------------------;
   if choice = "buyer" [
   ask x [
      set which-owner one-of y
      set label ""
      set which-occupied?  one-of y
      set h-price [bid] of one-of y
      set color pink + 2]]

   if choice = "jeonse" [
   ask x [
      set label ""
      set which-occupied? one-of y
      set j-price [bid] of one-of y
      set color pink + 2]]

   if choice = "walse" [
   ask x [
      set label ""
      set which-occupied? one-of y
      set w-price [bid] of one-of y
      set color pink + 2]]
end

;------------------------------------------------------------------------------------------------------;
;                                             go-home                                                  ;
;------------------------------------------------------------------------------------------------------;
to go-home
  if length homeless = 0 [stop]
  let thisperson first homeless
   ;--------------------------------------------#1-------------------------------------------;
     if gohyang thisperson != nobody[
;      ask thisperson [move-to gohyang thisperson]
      ask gohyang thisperson [set which-occupied? families thisperson]]
   ;--------------------------------------------#2-------------------------------------------;
    if gohyang thisperson = nobody and count ([own-house] of thisperson) with [not occupied?] > 0  [
      let destination nobody
      ask thisperson [
       set destination one-of own-house with [not occupied?]
;       move-to destination
       set home-status "jaga"]
      ask destination [
       set which-occupied? families thisperson
       set occupied? true]]
   ;--------------------------------------------#3-------------------------------------------;
;     user-message (word "household "[who] of ?2" is about to lost")
    if gohyang thisperson = nobody and count ([own-house] of thisperson) with [not occupied?] = 0 [
        let destination nobody
      foreach sort-on [who] houses with [not occupied?][?1 ->
       ask thisperson [
;          move-to ?1
          set destination ?1

      if destination != nobody [
          set cash cash - [w-price] of ?1
          set home-status "walse"]

       ask ?1 [set which-occupied? families thisperson]
       ask [which-owner] of ?1 [set cash cash + [w-price] of ?1]]]
   ;-------------------------------------------###-------------------------------------------;
      if destination != nobody [
      set TransactionVolume_walse TransactionVolume_walse + 1
;      user-message (word  "Auctioneer household " [who] of thisperson " was unable to find the house."
;                          "                                      "
;                          "Thus they decided to move into house "[who] of destination"."
;                          "                                            "
;                          "Contract Price is "precision [w-price] of destination 0" man won, in " [name] of [patch-here] of destination".")
       ask thisperson [hatch-walsejings 1 [
               set color pink + 4
               set shape "hexagonal prism"
               set seibja thisperson
               set which-house destination
               set jibjuin [which-owner] of destination     ;;;;;;; OF expected input to be a turtle agentset or turtle but got NOBODY instead.
               set purchasePrice [w-price] of destination
               set label ""
               place-walsejing]
      ]
    ]
     if destination = nobody [
      set daegisuyo (turtle-set thisperson daegisuyo)
;     user-message (word  "Household " [who] of thisperson " was unable to find the house.")
    ]
  ]
  set homeless but-first homeless
  set bidder bidder with [not member? self turtle-set thisperson]
  set auctioneer auctioneer with [not member? self turtle-set thisperson]
  set evicted evicted with [not member? self turtle-set thisperson]
;  foreach sort-on [who] (turtle-set bidder auctioneer evicted) [?1 ->
;    let destination nobody
;        foreach sort-on [who] houses with [count households-here = 0][?2 ->
;            ask ?1 [
;                move-to ?2
;                set destination ?2
;;                set cash cash - [w-price] of ?2
;                set cash cash - [utility-best] of ?1
;                set home-status "walse"
;                set label ""
;              ask ?2 [
;                set which-occupied? ?2]
;;              ask [which-owner] of ?2 [set cash cash + [w-price] of ?2]]]
;                ask [which-owner] of ?2 [set cash cash + [utility-best] of ?1]]]
;;           user-message (word  "Auctioneer household " [who] of ?1 " was unable to find the house."
;;                               "                                      "
;;                               "Thus they decided to move into house "[who] of destination"."
;;                               "                                            "
;;                               "Contract Price is "precision [w-price] of destination 0" man won, in " [name] of [patch-here] of destination".")
;           ask ?1 [hatch-walsejings 1 [
;                   set color pink + 4
;                   set shape "hexagonal prism"
;                   set seibja ?1
;                   set which-house destination
;                   set jibjuin [which-owner] of destination
;                   set purchasePrice [utility-best] of ?1
;                   set label ""
;                   place-walsejing]]
;  ]
  ask households [set home-x [pxcor] of patch-here set home-y [pycor] of patch-here]
  ask houses [set label "" set color pink + 2]
end

  ;-------------------------------------price-adjstment---------------------------------------;
to price-adjustment
;  if count bidder = 0 or seller = nobody [
;    if choice = "auction" [ask turtle-set [targethouse2] of auctioneer [set h-price h-price * (1 - 0.001 * count auctioneer)]]
;    if choice = "jeonse" [ask turtle-set [targethouse2] of auctioneer [set j-price min(list (0.95 * h-price) (j-price * (1 - 0.001 * count auctioneer)))]]
;    if choice = "walse" [ask turtle-set [targethouse2] of auctioneer [set w-price min (list (j-price / 24) (w-price * (1 - 0.001 * count auctioneer)))]]
;  ]
;  if count bidder != 0 [
;  if count auctioneer / count bidder > 1 [
;    if choice = "auction" [ask turtle-set [targethouse2] of auctioneer [set h-price h-price * (1 - 0.001 * count auctioneer)]]
;    if choice = "jeonse" [ask turtle-set [targethouse2] of auctioneer [set j-price min(list (0.95 * h-price) (j-price * (1 - 0.001 * count auctioneer)))]]
;    if choice = "walse" [ask turtle-set [targethouse2] of auctioneer [set w-price  min (list (j-price / 24) (w-price * (1 - 0.001 * count auctioneer)))]]
;  ]
;  ]
;  if count auctioneer = 0 or winner = nobody [
;    if choice = "auction" [ask turtle-set [targethouse] of bidder [set h-price h-price * (1 + 0.001 * count bidder)]]
;    if choice = "jeonse" [ask turtle-set [targethouse] of bidder [set j-price min(list (0.95 * h-price) (j-price * (1 + 0.001 * count bidder)))]]
;    if choice = "walse" [ask turtle-set [targethouse] of bidder [set w-price min (list (j-price / 24) (w-price * (1 + 0.001 * count bidder)))]]
;  ]
;  if count bidder != 0 [
;  if count auctioneer / count bidder < 1 [
;    if choice = "auction" [ask turtle-set [targethouse] of bidder [set h-price h-price * (1 + 0.001 * count bidder)]]
;    if choice = "jeonse" [ask turtle-set [targethouse] of bidder [set j-price min(list (0.95 * h-price) (j-price * (1 + 0.001 * count bidder)))]]
;    if choice = "walse" [ask turtle-set [targethouse] of bidder [set w-price min (list (j-price / 24) (w-price * (1 + 0.001 * count bidder)))]]
;  ]
;  ]

  if count bidder = 0 or seller = nobody [
    if choice = "auction" [ask object [set h-price h-price * (1 - 0.0001 * count auctioneer)]]
    if choice = "jeonse" [ask object [set j-price min(list (0.95 * h-price) (j-price * (1 - 0.0001 * (count auctioneer - count bidder))))]]
    if choice = "walse" [ask object [set w-price min (list (j-price / 24) (w-price * (1 - 0.0001 * (count auctioneer - count bidder))))]]
  ]
  if count bidder != 0 [
  if count auctioneer / count bidder > 1 [
    if choice = "auction" [ask object [set h-price h-price * (1 - 0.0001 * count auctioneer)]]
    if choice = "jeonse" [ask object [set j-price min(list (0.95 * h-price) (j-price * (1 - 0.0001 * (count auctioneer - count bidder))))]]
    if choice = "walse" [ask object [set w-price  min (list (j-price / 24) (w-price * (1 - 0.0001 * (count auctioneer - count bidder))))]]
  ]
  ]
  if count auctioneer = 0 or winner = nobody [
    if choice = "auction" [ask object [set h-price h-price * (1 + 0.0001 * count bidder)]]
    if choice = "jeonse" [ask object [set j-price min(list (0.95 * h-price) (j-price * (1 + 0.0001 * (count bidder - count auctioneer))))]]
    if choice = "walse" [ask object [set w-price min (list (j-price / 24) (w-price * (1 + 0.0001 * (count bidder - count auctioneer))))]]
  ]
  if count bidder != 0 [
  if count auctioneer / count bidder < 1 [
    if choice = "auction" [ask object [set h-price h-price * (1 + 0.0001 * count bidder)]]
    if choice = "jeonse" [ask object [set j-price min(list (0.95 * h-price) (j-price * (1 + 0.0001 * (count bidder - count auctioneer))))]]
    if choice = "walse" [ask object [set w-price min (list (j-price / 24) (w-price * (1 + 0.0001 * (count bidder - count auctioneer))))]]
  ]
  ]

;  if count bidder = 0 or seller = nobody [
;    if choice = "auction" [ask houses [set h-price h-price * (1 - 0.001 * count auctioneer)]]
;    if choice = "jeonse" [ask houses [set j-price min(list (0.95 * h-price) (j-price * (1 - 0.001 * count auctioneer)))]]
;    if choice = "walse" [ask houses [set w-price  min (list (j-price / 24) (w-price * (1 - 0.001 * count auctioneer)))]]
;  ]
;  if count bidder != 0 [
;  if count auctioneer / count bidder > 1 [
;    if choice = "auction" [ask houses [set h-price h-price * (1 - 0.001 * count auctioneer)]]
;    if choice = "jeonse" [ask houses [set j-price min(list (0.95 * h-price) (j-price * (1 - 0.001 * count auctioneer)))]]
;    if choice = "walse" [ask houses [set w-price min (list (j-price / 24) (w-price * (1 - 0.001 * count auctioneer)))]]
;  ]
;  ]
;
;  if count auctioneer = 0 or winner = nobody [
;    if choice = "auction" [ask houses [set h-price h-price * (1 + 0.001 * count bidder)]]
;    if choice = "jeonse" [ask houses [set j-price min(list (0.95 * h-price) (j-price * (1 + 0.001 * count bidder)))]]
;    if choice = "walse" [ask houses [set w-price  min (list (j-price / 24) (w-price * (1 + 0.001 * count bidder)))]]
;  ]
;  if count bidder != 0 [
;  if count auctioneer / count bidder < 1 [
;    if choice = "auction" [ask houses [set h-price h-price * (1 + 0.001 * count bidder)]]
;    if choice = "jeonse" [ask houses [set j-price min(list (0.95 * h-price) (j-price * (1 + 0.001 * count bidder)))]]
;    if choice = "walse" [ask houses [set w-price min (list (j-price / 24) (w-price * (1 + 0.001 * count bidder)))]]
;  ]
;  ]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                         report-balance-sheet                                         ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to report-balance-sheet
;  if ticks = 0 [ multi-helikopter ]
   if ticks = 10000 [
    ;user-message  (word "tick 15000 has been reached. Checksum: " round ((100 * sum [Cash] of Households with [who = 15]) + (1000 * sum [reserve] of Banks with [who = 3]))  )
   ]
   if-else count Banks with [bancrupt = true] > 0 [
     ;set reserve-ratio 0.04
   ] [
     ;set reserve-ratio 0.04
   ]
   if ticks mod 2000  =  0  [ ; Add a new entry to the transaction volume list and plot the histogram
     if length TransactionVolume > 0 [
;       set-current-plot "plot 2"
;       plotxy TransactionVolume_timer (item (length TransactionVolume - 1) TransactionVolume)
;       set  TransactionVolume_timer  TransactionVolume_timer + 2000
;       plotxy TransactionVolume_timer (item (length TransactionVolume - 1) TransactionVolume)
   ]
    set TransactionVolume lput 0 TransactionVolume
   ]
    Repay-IBCredits  ; This function checks if some IB-Credits have to by repaied this tick. If so the payment is performed

   if count Banks > 0 or count Households > 0 [   ; If there is at least one BA or HH left ...
     Households-go             ;       let HHs act
     Banks-go                  ;       let BAs act
     Print-BalanceSheet        ;       fill text panel at the right
     Kill-Bancrupt-Banks       ;       remove bankrupt BAs from the market if their die_tick is reached
   ]
   set M0 sum [cash] of Households + sum [cash] of Banks + sum [Reserve] of Banks       ; calculate the monetary aggregates
   set M1 sum [cash] of Households + sum [deposits] of Households
   set Aggr_CreditsToHH sum [loan] of Households
   ifelse count IBCredits > 0 [
     set Sum_Interbank_Credits sum [amount] of IBCredits
   ] [
    set Sum_Interbank_Credits 0
   ]

  set TransactionVolume (list TransactionVolume_house TransactionVolume_jeonse TransactionVolume_walse)

  set ticks_to_highlight_agent ticks_to_highlight_agent - 1  ; check if the highlight-circle has to be removed from an agent
  if ticks_to_highlight_agent <= 0 [
    set ticks_to_highlight_agent 0
    reset-perspective
  ]
  ask Fires [ every 0.8 [ ifelse shape = "fire2" [set shape "fire"] [set shape "fire2"] ] ]        ; The burning-animation of fires
end

to preparation
  set choice2 "buyer"
  foreach sort-on [who] making-electorate [?1 -> value-iteration ?1]
  set choice2 "seller"
  foreach sort-on [who] making-electorate with [count making-whoofhouse self > 0] [?1 -> value-iteration ?1]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                           Households-go                                              ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to Households-go
  ask making-electorate [
    set  individual-cash-ratio  cash-ratio    ; if the slider "cash-ratio" has been changed, the HHs parameter must also be set
    ifelse [bancrupt] of Bank myBank_dep  =  true   [ set cash_wanted cash + deposits ]
                                                    [ set cash_wanted individual-cash-ratio / (1 + individual-cash-ratio) * (spending + mortgage-payment self + item 1 giver self - item 1 receiver self - interest-earnings self - income + cash + deposits + silmul)]

    set home-x [pxcor] of patch-here
    set home-y [pycor] of patch-here
        face targethouse
        move-to targethouse
        ;fd 0.5
        ask families self [move-to self]

          ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]

;         set bidder households with [targethouse = [targethouse] of self and auction_name = [auction_name] of self]
        ifelse distance targethouse < 1.5[
          set choice [auction_name] of self
          setup-auction targethouse
         repeat 32 [auction targethouse]
    ][
                                                                       ; Mode 0: C = q * D is matched  -->  perform random walk
    if mode = 0 [
      setxy home-x home-y
      if  cash > cash_wanted - small_value  and  cash < cash_wanted + small_value  [
        set color blue
      ]

      if  cash < cash_wanted - small_value  [
        ifelse  (0 = count  Households with [mode = 1 and myBank_dep = [myBank_dep] of myself]) or (Bank-Runs? = true) [      ;; if no agent with same Bank_dep is alsready in mode 1
          set mode 1                                                                                 ;; set my mode to 1
          set color red
         ][
          face targethouse                                                                     ;; otherwise do normal mode 0 activity
          fd 0.5
          ask families self [move-to self]

            ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]
        ]
      ]
      if  cash > cash_wanted + small_value  [
        set color green
        set mode 2
      ]
  ]

    if mode = 1 [  ; Mode 1: not enough cash -> pick up money from myBank_dep
      setxy home-x home-y
      ifelse  cash < cash_wanted - small_value  [
         ifelse distance Bank myBank_dep < 1.5 [
          let cash_to_transfer min (list 100 (cash_wanted - cash) [cash + Reserve] of Bank myBank_dep)
          ifelse cash_to_transfer > small_value [ ;;small_value * 0.01 [
            let from_cash min (list cash_to_transfer [cash] of Bank myBank_dep)      ;; how much will the bank pay from cash
            ;let from_reserve min (list (cash_to_transfer - from_cash) ([Reserve] of Bank myBank_dep))      ;; how much will the bank pay from reserves
            let from_reserve cash_to_transfer - from_cash
            set cash cash + cash_to_transfer
            set deposits deposits - cash_to_transfer
            ask Bank myBank_dep [
              set cash cash - from_cash
              set Reserve Reserve - from_reserve
          ]
         ][
           if [bancrupt] of Bank myBank_dep = false [
              show (word "Household " who ": '' Hey everybody, bank " myBank_dep " can not pay anymore :-( ''" )
              ask Bank myBank_dep [     ; mark bank as bancrupt (same function is included in repay credit)
                set bancrupt true
                set die_tick ticks + 1000
                watch-me
                hatch-Fires 1 [
                  set ycor ycor + 0.9
                  set label ""
                  set shape "fire"
                  set color 0
                  set size 1.5
                  set myBank [who] of myself
                ]
              ]
              set BankToShowBalance myBank_dep
              set ticks_to_highlight_agent 15
            ]
          ]
       ][
          face Bank myBank_dep
          fd 0.5
          ask families self [move-to self]
          ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]

        ]
      ] [
        face targethouse
        set color blue
        set mode 0
      ]
    ]
    if mode = 2 [                                            ; Mode 2: too much cash --> bring some cash to myBank_dep
      setxy home-x home-y
      ifelse  cash > cash_wanted + small_value  [
        ifelse  distance Bank myBank_dep  < 1.5  [
          let cash_to_transfer min (list (cash - cash_wanted)  cash)
          set cash cash - cash_to_transfer
          set deposits deposits + cash_to_transfer
          ask bank myBank_dep [set cash cash + cash_to_transfer]

;          set choice [auction_name] of self
;;         set bidder households with [targethouse = [targethouse] of self and auction_name = [auction_name] of self]
;        if distance targethouse < 1.5[
;          setup-auction targethouse
;          auction targethouse
;        ]

     ][
          face Bank myBank_dep
          fd 0.5
          ask families self [move-to self]
          ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]


        ]
      ] [
        face targethouse
        set color blue
        set mode 0
      ]
    ]

    if mode = 3 [ ; Mode 3: take from myBank_loan ;; myBank_loan is reached
      setxy home-x home-y
      ifelse  distance Bank myBank_loan < 1.5 [
        let cash_to_transfer min (list 100 money_to_take_next  ([cash] of Bank myBank_loan / (1 + reserve-ratio)) )
        ifelse cash_to_transfer > small_value [;; > small_value * 0.01 [                                                                ;; take a loan from the bank
          set cash cash + cash_to_transfer
          set money_to_take_next money_to_take_next - cash_to_transfer
          set taken_loan taken_loan + cash_to_transfer
          set loan loan + cash_to_transfer
          ask Bank myBank_loan [
            set cash cash - cash_to_transfer * (1 + reserve-ratio)
            set Reserve Reserve + ( cash_to_transfer * reserve-ratio )
          ]
        ] [                                                                                                         ;; full loan is taken
          set mode 4
          set color cyan
          set money_to_take_next 100
        ]
    ][
        set color cyan
        set money_to_take_next max (list 0.1 (random-float 1 * [cash] of Bank myBank_loan) )
        set taken_loan 0
        face Bank myBank_loan
        fd 0.5
        ask families self [move-to self]
          ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]



      ]
    ]

    if mode = 4 [                                                                             ; Mode 4: give borrowed money to some other Household
      setxy home-x home-y
      let possiblePartner min-one-of Households with [mode = 0] [distance myself]
      ifelse possiblePartner != NOBODY [
        ;ifelse cash > cash_wanted + small_value [
         ifelse  distance possiblePartner < 1.2  and  distance min-one-of Banks [distance myself] > 4 [
            let cash_to_transfer min (list 100 taken_loan cash)
            set cash cash - cash_to_transfer
            ask possiblePartner [ set cash cash + cash_to_transfer ]
            set mode 0
;            set  TransactionVolume  replace-item  (length TransactionVolume - 1)  TransactionVolume  ((last TransactionVolume) + cash_to_transfer)
      ] [
        face targethouse
        fd 0.5
        ask families self [move-to self]
          ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]


        ]
       ][
        set mode 1   ; if no trading partner exists: skip mode 4, pay money into myBankd_dep
      ]
    ]

    if mode = 5 [                                                ; Mode 5: Bank_loan wants money back
      setxy home-x home-y
      ifelse  distance Bank myBank_loan < 1.5  [
        let Reserve_wanted (sum [deposits] of Households with [myBank_dep = [myBank_loan] of myself]) * reserve-ratio
        let cash_that_bank_needs Reserve_wanted - [Reserve + Cash] of Bank myBank_loan
        let cash_to_transfer max (list 100 cash cash_that_bank_needs)
        set cash cash - cash_to_transfer
        set loan loan - cash_to_transfer
        ask Bank myBank_loan [
          set cash cash + cash_to_transfer
        ]
        if  cash < small_value  or  cash_that_bank_needs < small_value  [       ; payed back as much as possible: return to mode 0
          face targethouse
          set color blue
          set mode 0
        ]
    ][
        face Bank myBank_loan
        fd 0.5
        ask families self [move-to self]
          ;-------------------------------------family----------------------------------------;

          foreach sort-on [who] households [?1 ->
           ask ?1 [
            set home-x [pxcor] of [patch-here] of ?1
            set home-y [pycor] of [patch-here] of ?1
            ]
          ]

      ]
    ]
    ifelse show-money? [ set label (word (precision cash 1) "/" (precision deposits 1)) set label-color blue ] [set label ""]
    ]
  ]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                                Banks-go                                              ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to Banks-go
  ask links with [ birth_tick < ticks - 10 ] [ die ]
  ask Banks [
    let hh_depts (sum [deposits] of Households with [myBank_dep = [who] of myself])              ;; Calculate Liability-entry "deposits of households"
    let Reserve_wanted hh_depts * reserve-ratio                                               ;; Calculate wanted level of reserves

    if Reserve > Reserve_wanted + small_value [
      set cash cash + Reserve - Reserve_wanted
      set Reserve Reserve - (Reserve - Reserve_wanted)
    ]
    if Reserve < Reserve_wanted - small_value [                                               ;; If reserves are too low
      ifelse cash > small_value [                                                                  ;; First: Try to transfer own cash to reserves
        let cash_to_transfer min (list 100 cash (Reserve_wanted - Reserve))
        set cash cash - cash_to_transfer
        set Reserve Reserve + cash_to_transfer
      ] [
        let PossibilyLendingBank max-one-of other Banks [cash]
        ifelse  Interbank-market? = true  and PossibilyLendingBank != nobody  and  small_value < [cash] of PossibilyLendingBank  and  bancrupt = false  [    ;; Second: Try to get money on the inter-bank market
          let cash_to_transfer min (list (Reserve_wanted - Reserve) [cash] of PossibilyLendingBank)
          create-link-from PossibilyLendingBank [ set birth_tick ticks ]
          set cash cash + cash_to_transfer
          ask PossibilyLendingBank [
            set cash cash - cash_to_transfer
          ]
          hatch-IBCredits 1 [
            set lender [who] of PossibilyLendingBank
            set borrower [who] of myself
            set amount cash_to_transfer
            set start_tick ticks
            set end_tick ticks + 1000 + random 1000
            set xcor xcor + random-float 5 + 2
            set ycor ycor + random-float 5 - 2.5
            set label (precision amount 2)
            set shape "default"
            set color 2
            set size 1.5
            set hidden? true
          ]
          ;show (word "Interbank market: Bank " [who] of PossibilyLendingBank " --> Bank " who " ,  " cash_to_transfer)
        ] [                                                                                      ;; Third: Order credit of one household back
          set color red
          set BA_mode 2        ;  Reserve too low but no cash
          if  0 = count Households with [mode = 5 and myBank_loan = [who] of myself]  [                  ;; No Household is coming to bank to bring back money
            let possibleTP max-one-of Households with [myBank_loan = [who] of myself and loan > small_value * 0.1 and cash > small_value * 0.1] [distance myself]
            if possibleTP != nobody [
              ask possibleTP [
                set mode 5
                set color cyan
              ]
            ]
          ]
        ]
      ]
    ]
    if  Reserve > Reserve_wanted - small_value  and  Reserve < Reserve_wanted + small_value [
      ifelse cash > small_value [
        set BA_mode 1        ;  Reserve matched but still cash left
        set color green
        let Bank_who who
        if  0 = count Households with [mode = 3  and  myBank_loan = bank_who] [                        ;; nobody is going to the bank and taking the cash
          let possibleDebtor max-one-of Households with [mode = 0  and  myBank_loan = bank_who] [distance myself]
          if possibleDebtor != Nobody  [ ask possibleDebtor [ set mode 3 ]  ]
        ]
      ] [
        set color blue
        set BA_mode 0        ;  Reserve ratio is matched and cash is zero
      ]
    ]
    ifelse show-money? [set label (word (precision cash 1) "/" (precision reserve 1) ) set label-color gray - 3 ] [set label ""]

    if bancrupt = true [
      set BA_mode 3                   ; overwrite otherwise set values
    ]
  ]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                                IBCredit                                              ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to Repay-IBCredits
  let BankruptBank false
  let Bankruptcy_message ""
  ask IBCredits with [ end_tick <= ticks ]  [
    ;show borrower
    ifelse  ([cash + reserve] of one-of Banks with [who = [borrower] of myself])  >=  amount - small_value [
      let cash_to_transfer min(list amount [cash + reserve] of one-of Banks with [who = [borrower] of myself])
      ask one-of Banks with [who = [borrower] of myself]  [
        let from_cash min(list cash_to_transfer cash)
        let from_reserve cash_to_transfer - from_cash
        set cash cash - from_cash
        set reserve reserve - from_reserve
      ]
      ask one-of Banks with [who = [lender] of myself]  [
        set cash cash + cash_to_transfer
        create-link-to Bank [borrower] of myself  [ set birth_tick ticks ]
      ]
      die
    ] [     ;; IBCredit can not be repaid  -->  Transfer as much as possible and postpone IBCredit
      let cash_to_transfer min(list amount [cash + reserve] of one-of Banks with [who = [borrower] of myself])
      if cash_to_transfer > small_value [
        let from_cash min(list   cash_to_transfer   ([cash] of one-of Banks with [who = [borrower] of myself]))
        let from_reserve cash_to_transfer - from_cash
        ;show (word amount  " --> " cash_to_transfer)
        ask one-of Banks with [who = [borrower] of myself]  [
          set cash cash - from_cash
          set reserve reserve - from_reserve
        ]
        ;show lender
        ask one-of Banks with [who = [lender] of myself]  [
          set cash cash + from_cash + from_reserve
          create-link-to Bank [borrower] of myself  [ set birth_tick ticks ]
        ]
        set amount amount - cash_to_transfer
      ]
      set end_tick end_tick + 1

      if [bancrupt] of Bank borrower  =  false [
        set BankToShowBalance borrower
        ask Bank borrower [     ; mark bank as bancrupt (same function is included in household pick up money from bank)
          set bancrupt true
          set die_tick ticks + 1000
          watch-me
          hatch-Fires 1 [
            set ycor ycor + 0.9
            set label ""
            set shape "fire"
            set color 0
            set size 1.5
            set myBank [who] of myself
          ]
        ]
        set BankruptBank true                  ;; to reprint the balance sheet of bankrupt bank (below)
        set Bankruptcy_message (word "IBCredit " who " has to be repayed. But Bank " borrower " has not enough money. " amount " units were needed.")
      ]
    ]
  ]
  if BankruptBank [
    Print-BalanceSheet
    show Bankruptcy_message
  ]
end

;------------------------------------------------------------------------------------------------------;
;                                          kill-bancrupt-banks                                         ;
;------------------------------------------------------------------------------------------------------;
to Kill-Bancrupt-Banks
  let BankToKill one-of Banks with [die_tick <= ticks and die_tick > 0 and (cash + reserve) < small_value]

  if BankToKill != Nobody [
    let who_of_bancrupt_bank [who] of (BankToKill)
    show (word "Bank " who_of_bancrupt_bank " is removed")
    ;show (word  [cash] of (BankToKill) " " [reserve] of (BankToKill) " " [equity] of (BankToKill) " " [bancrupt] of (BankToKill) " " [die_tick] of (BankToKill) )
    ask BankToKill [ die ]      ; kill the bank
    ;; kill all financial conections of the bank
    ask Households with [myBank_dep = who_of_bancrupt_bank]  [
      set deposits 0
      let New_Bank_dep one-of Banks with [bancrupt = false]
      if-else New_Bank_dep != nobody [
        set myBank_dep [who] of New_Bank_dep
      ] [
        ; if no non-bankrupt BA is found try a bakrupt one instead
        set New_Bank_dep one-of Banks with [who != [myBank_dep] of myself]
        if New_Bank_dep != nobody [
          set myBank_dep [who] of New_Bank_dep
        ]
      ]
    ]
    ask Households with [myBank_loan = who_of_bancrupt_bank]  [
      set loan 0
      set myBank_loan myBank_dep       ; to make shure the loop is executet at least once
      while [ myBank_loan = myBank_dep and count Banks >= 2 ] [
        let New_Bank_loan one-of Banks
        if New_Bank_loan != nobody [
          set MyBank_loan [who] of New_Bank_loan
        ]
      ]
      if myBank_dep = myBank_loan and count Banks > 1 [ user-message (word "Error: myBank_dep = myBank_loan,  Bank No.: " myBank_dep)]
    ]
    ask IBCredits with [borrower = who_of_bancrupt_bank]  [ die ]
    ask IBCredits with [lender = who_of_bancrupt_bank]  [ die ]
    ask Fires with [myBank = who_of_bancrupt_bank] [ die ]
  ]

end

to Helikopter
  ask one-of Households with [5 < distance min-one-of Banks [distance myself]] [
    set cash cash + 1E4
    watch-me
    set ticks_to_highlight_agent 15
    set HouseholdToShowBalance who
    set BankToShowBalance myBank_dep
    set Show-Individuals? true
  ]
end

to multi-Helikopter
  ask Households [set cash cash + 1E4]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                           Print-BalanceSheet                                         ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
to Print-BalanceSheet
  if Show-Balance-Sheets? = true [

    if Household HouseholdToShowBalance = nobody [
      set HouseholdToShowBalance [who] of making-electorate]

    if Bank BankToShowBalance = nobody [
      set BankToShowBalance [who] of Banks]

    ask Households [ set equity cash + deposits + silmul - loan ]
    ask Banks [ set equity cash + reserve + (sum ([loan] of Households with [myBank_loan = [who] of myself])) + (sum [amount] of IBCredits with [lender = [who] of myself]) - (sum ([deposits] of Households with [myBank_dep = [who] of myself])) - (sum [amount] of IBCredits with [borrower = [who] of myself]) ]
    let EmptyString "                 "

    ;; Banks: Calculate entries as numbers
    ifelse Show-Individuals? = true [
      set BA_entry_cash precision ([cash] of Bank BankToShowBalance) 0
      set BA_entry_reserve precision ([Reserve] of Bank BankToShowBalance) 0
      set BA_entry_Credits_toHH (precision ([sum ([loan] of Households with [myBank_loan = [who] of myself])] of Bank BankToShowBalance) 0)
      set BA_entry_Credits_toBA precision (   sum [amount] of IBCredits with [lender = BankToShowBalance]   ) 0
      set BA_entry_loans_fromBA precision (   sum [amount] of IBCredits with [borrower = BankToShowBalance]    ) 0
      set BA_entry_total precision (BA_entry_cash + BA_entry_reserve + BA_entry_Credits_toHH + BA_entry_Credits_toBA) 0
      set BA_entry_deposits precision (sum ([deposits] of Households with [myBank_dep = BankToShowBalance])) 0
      set BA_entry_equity (word (precision ([equity] of Bank BankToShowBalance) 0))
    ] [
      set BA_entry_cash precision (sum [cash] of Banks) 0
      set BA_entry_reserve precision (sum [Reserve] of Banks) 0
      set BA_entry_Credits_toHH (precision sum [loan] of Households 0)
      set BA_entry_Credits_toBA precision (   0   ) 0
      set BA_entry_loans_fromBA precision (   0   ) 0
      set BA_entry_total precision (BA_entry_cash + BA_entry_reserve + BA_entry_Credits_toHH + BA_entry_Credits_toBA) -6
      set BA_entry_deposits precision (sum [deposits] of Households) 0
      set BA_entry_equity (word (precision (sum [equity] of Banks) 0))
    ]

    ;; Households: Calculate entries as numbers
    ifelse Show-Individuals? = true [
      set HH_entry_cash precision ([cash] of Household HouseholdToShowBalance) 0
      set HH_entry_deposits precision ([deposits] of Household HouseholdToShowBalance) 0
      set HH_entry_loan precision ([loan] of Household HouseholdToShowBalance) 0
      set HH_entry_silmul precision ([silmul] of Household HouseholdToShowBalance) 0
      set HH_entry_total precision (HH_entry_cash + HH_entry_deposits + HH_entry_silmul) 0
      set HH_entry_equity precision ([equity] of Household HouseholdToShowBalance) 0
    ] [
      set HH_entry_cash precision (sum [cash] of Households) 0
      set HH_entry_deposits precision (sum [deposits] of Households) 0
      set HH_entry_loan precision (sum [loan] of Households) 0
      set HH_entry_silmul precision (sum [silmul] of Households) 0
      set HH_entry_total precision (HH_entry_cash + HH_entry_deposits + HH_entry_silmul) 0
      set HH_entry_equity precision (sum [equity] of Households) 0
    ]

    let currency_entry_CB precision (sum [cash] of Banks + sum [cash] of Households) 0                       ;; CB: Calculate entries as numbers
    let dept_entry_CB precision (sum [Reserve] of Banks) 0
    let equity_entry_CB precision (0 - currency_entry_CB - dept_entry_CB) 0
    let sum_all_equities precision (sum [equity] of Banks + sum [equity] of Households + equity_entry_CB) 0

;    if abs(sum_all_equities) > 0.1 [
;      user-message (word "Sum of equities is " (precision sum_all_equities 0))
;    ]

    let HH_thinking ""
    if [mode] of Household HouseholdToShowBalance = 0 [
      set HH_thinking "I am fine. Cash ratio is matched."
    ]
    if [mode] of Household HouseholdToShowBalance = 1 [
;      let cash_wanted [cash-ratio / (1 + cash-ratio) * (cash + deposits)] of Household HouseholdToShowBalance
      set HH_thinking (word "I want more cash. Take " precision ([cash_wanted - cash] of Household HouseholdToShowBalance) 2 " from my account at bank " [myBank_dep] of Household HouseholdToShowBalance ".")
    ]
    if [mode] of Household HouseholdToShowBalance = 2 [
      set HH_thinking (word "I have too much cash. Pay " precision ([cash - cash_wanted] of Household HouseholdToShowBalance) 2 " man won into account of bank " [myBank_dep] of Household HouseholdToShowBalance ".")
    ]
    if [mode] of Household HouseholdToShowBalance = 3 [
      set HH_thinking (word "Bank " [myBank_loan] of Household HouseholdToShowBalance " offers a good loan. I want to apply for it.")
    ]
    if [mode] of Household HouseholdToShowBalance = 4 [
      set HH_thinking (word "Whith the new loan I'm going to buy myself something.")
    ]
    if [mode] of Household HouseholdToShowBalance = 5 [
      ifelse [cash] of Household HouseholdToShowBalance > 0 [
        set HH_thinking (word "Bank " [myBank_loan] of Household HouseholdToShowBalance " wants it's money back. No problem.")
      ] [
      set HH_thinking (word "Bank " [myBank_loan] of Household HouseholdToShowBalance " wants it's money back. But I'm broke :-(")
      ]
    ]

    let BA_thinking ""
    if [BA_mode] of Bank BankToShowBalance = 0 [
      set BA_thinking "I am fine. Reserve ratio is matched."
    ]
    if [BA_mode] of Bank BankToShowBalance = 1 [
      set BA_thinking "I got too much money: Does anybody want a credit?"
    ]
    if [BA_mode] of Bank BankToShowBalance = 2 [
      set BA_thinking "I need money to obey reserve ratio."
    ]
    if [BA_mode] of Bank BankToShowBalance = 3 [
      set BA_thinking "I'm insolvent: Withdraw all credits and do not grant any new."
    ]


    if   timer > 0.1   and   (   timer > 10   or   BA_entry_cash_previous != BA_entry_cash   or   BA_entry_reserve_previous != BA_entry_reserve   or   BA_entry_Credits_toHH_previous != BA_entry_Credits_toHH   or   BA_entry_Credits_toBA_previous != BA_entry_Credits_toBA   or   BA_entry_loans_fromBA_previous != BA_entry_loans_fromBA   or   BA_entry_total_previous != BA_entry_total   or   BA_entry_deposits_previous != BA_entry_deposits   or   BA_entry_equity_previous != BA_entry_equity   or   HH_entry_cash_previous != HH_entry_cash   or   HH_entry_deposits_previous != HH_entry_deposits   or   HH_entry_loan_previous != HH_entry_loan   or   HH_entry_total_previous != HH_entry_total   or   HH_entry_equity_previous != HH_entry_equity   or   CB_entry_currency_previous != currency_entry_CB   or   CB_entry_dept_previous != dept_entry_CB   or   CB_entry_equity_previous != equity_entry_CB   or   HH_thinking_previous != HH_thinking   or   BA_thinking_previous != BA_thinking   or   HouseholdToShowBalance_previous != HouseholdToShowBalance   or   BankToShowBalance_previous != BankToShowBalance   )   [
      reset-timer
      set BA_entry_cash_previous BA_entry_cash                ;; save all current values
      set BA_entry_reserve_previous  BA_entry_reserve
      set BA_entry_Credits_toHH_previous BA_entry_Credits_toHH
      set BA_entry_total_previous BA_entry_total
      set BA_entry_deposits_previous BA_entry_deposits
      set BA_entry_equity_previous BA_entry_equity
      set HH_entry_cash_previous HH_entry_cash
      set HH_entry_deposits_previous HH_entry_deposits
      set HH_entry_silmul_previous HH_entry_silmul
      set HH_entry_loan_previous HH_entry_loan
      set HH_entry_total_previous HH_entry_total
      set HH_entry_equity_previous HH_entry_equity
      set CB_entry_currency_previous currency_entry_CB
      set CB_entry_dept_previous dept_entry_CB
      set CB_entry_equity_previous equity_entry_CB
      set HH_thinking_previous HH_thinking
      set BA_thinking_previous BA_thinking
      set HouseholdToShowBalance_previous HouseholdToShowBalance
      set BankToShowBalance_previous BankToShowBalance

      set BA_entry_cash (word BA_entry_cash)                                                   ;; Banks: Convert values to string
      set BA_entry_cash (word (substring EmptyString 0 (18 - length BA_entry_cash)) BA_entry_cash " ")
      set BA_entry_reserve (word BA_entry_reserve)
      set BA_entry_reserve (word (substring EmptyString 0 (18 - length BA_entry_reserve)) BA_entry_reserve " ")
      set BA_entry_Credits_toHH (word BA_entry_Credits_toHH)
      set BA_entry_Credits_toHH (word (substring EmptyString 0 (15 - length BA_entry_Credits_toHH)) BA_entry_Credits_toHH " ")
      set BA_entry_Credits_toBA (word BA_entry_Credits_toBA)
      set BA_entry_Credits_toBA (word (substring EmptyString 0 (15 - length BA_entry_Credits_toBA)) BA_entry_Credits_toBA " ")
      set BA_entry_loans_fromBA (word BA_entry_loans_fromBA)
      set BA_entry_loans_fromBA (word (substring EmptyString 0 (15 - length BA_entry_loans_fromBA)) BA_entry_loans_fromBA " ")
      set BA_entry_total (word BA_entry_total)
      set BA_entry_total (word (substring EmptyString 0 (18 - length BA_entry_total)) BA_entry_total " ")
      set BA_entry_deposits (word BA_entry_deposits)
      set BA_entry_deposits (word (substring EmptyString 0 (18 - length BA_entry_deposits)) BA_entry_deposits " ")
      set BA_entry_equity (word (substring EmptyString 0 (18 - length BA_entry_equity)) BA_entry_equity " ")
      set HH_entry_cash (word HH_entry_cash)                                                   ;; Household: Convert values to string
      set HH_entry_cash (word (substring EmptyString 0 (18 - length HH_entry_cash)) HH_entry_cash " ")
      set HH_entry_deposits (word HH_entry_deposits)
      set HH_entry_deposits (word (substring EmptyString 0 (18 - length HH_entry_deposits)) HH_entry_deposits " ")
      set HH_entry_silmul (word HH_entry_silmul)
      set HH_entry_silmul (word (substring EmptyString 0 (18 - length HH_entry_silmul)) HH_entry_silmul " ")
      set HH_entry_loan (word HH_entry_loan)
      set HH_entry_loan (word (substring EmptyString 0 (18 - length HH_entry_loan)) HH_entry_loan " ")
      set HH_entry_total (word HH_entry_total)
      set HH_entry_total (word (substring EmptyString 0 (18 - length HH_entry_total)) HH_entry_total " ")
      set HH_entry_equity (word HH_entry_equity)
      set HH_entry_equity (word (substring EmptyString 0 (18 - length HH_entry_equity)) HH_entry_equity " ")
      set currency_entry_CB (word currency_entry_CB)                                                   ;; Household: Convert values to string
      set currency_entry_CB (word (substring EmptyString 0 (18 - length currency_entry_CB)) currency_entry_CB " ")
      set dept_entry_CB (word dept_entry_CB)
      set dept_entry_CB (word (substring EmptyString 0 (18 - length dept_entry_CB)) dept_entry_CB " ")
      set equity_entry_CB (word equity_entry_CB)
      set equity_entry_CB (word (substring EmptyString 0 (18 - length equity_entry_CB)) equity_entry_CB " ")


      clear-output
      output-print "                                                                                                        Central Bank"
      output-print "        ASSETS       |    LIABILITIES                 ASSETS     |    LIABILITIES                ASSETS       |    LIABILITIES"
      output-print "---------------------+-------------------      ------------------+-------------------      -------------------+-------------------"
      output-print (word " Cash                | HH deposits              Cash             | Loan Bank "([myBank_loan] of Household HouseholdToShowBalance)"                                | Currency")
      output-print (word "  "BA_entry_cash"|" BA_entry_deposits "     " HH_entry_cash "|" HH_entry_loan"                         |" currency_entry_CB)
      output-print (word " Reserves            | Credits                  Deposits "([myBank_dep] of Household HouseholdToShowBalance)"       |                                            | BA Deposits")
      output-print (word "  "BA_entry_reserve"| Ba"BA_entry_loans_fromBA "     "HH_entry_deposits"|                                            |"dept_entry_CB)
      output-print " Out. Loans          |                          Silmul           |                                            |"
      output-print (word "  hh " BA_entry_Credits_toHH "| Equity                 "HH_entry_silmul"| Equity                                     | Equity")
      output-print (word "  ba " BA_entry_Credits_toBA "|" BA_entry_equity  "                        |"HH_entry_equity"                         |"equity_entry_CB)
      output-print "---------------------+-------------------      ------------------+-------------------      -------------------+-------------------"
      output-print (word "  "BA_entry_total"|" BA_entry_total "     " HH_entry_total    "|" HH_entry_total "                       0 |                 0")
      output-print ""
      ifelse Show-Individuals? = true [
        output-print (word "Bank " BankToShowBalance ": " BA_thinking)
        output-print (word "Households " HouseholdToShowBalance ": " HH_thinking)
      ] [
        output-print ""
        output-print ""
      ]
      output-print ""
      output-print (word "sum of all individual equities = " sum_all_equities)


;      set-current-plot "Liquidity Forecast"
;      clear-plot
;      set-current-plot-pen "pen-0"
;      plot-pen-reset
      let AllMyCredits  IBCredits with [lender = BankToShowBalance  or  borrower = BankToShowBalance]
      set AllMyCredits   sort-on [end_tick] AllMyCredits

      let cash_prediction 0
      ifelse Show-Individuals? = true [
        set cash_prediction [cash + reserve] of Bank BankToShowBalance
;        plotxy ticks cash_prediction
        foreach AllMyCredits  [ ?1 ->
          plotxy  [end_tick] of ?1  cash_prediction
          ifelse  BankToShowBalance = [lender] of ?1  [
            set cash_prediction cash_prediction + [amount] of ?1
          ] [
          set cash_prediction cash_prediction - [amount] of ?1
          ]
;          plotxy  [end_tick] of ?1  cash_prediction
        ]
      ] [
        set cash_prediction sum [cash + reserve] of Banks
;        plotxy ticks cash_prediction
        if count IBCredits > 0 [
;          plotxy max [end_tick] of IBCredits cash_prediction
        ]
      ]

;      set-current-plot-pen "pen-1"                    ;; The x-axis
;      plot-pen-reset
;      plotxy plot-x-min 0
;      plotxy plot-x-max 0
;      set-plot-x-range ticks ticks + 2500

;      set-current-plot "plot 1"             ;; second plot
;      clear-plot
;      set-current-plot-pen "assets"
;      plot-pen-reset
      let credit_now 0
      ifelse Show-Individuals? = true [
        set credit_now sum [amount] of IBCredits with [lender = BankToShowBalance]
;        plotxy ticks credit_now
;        set-plot-x-range ticks ticks + 1
        set AllMyCredits  IBCredits with [lender = BankToShowBalance]
        set AllMyCredits  sort-on [end_tick] AllMyCredits
        foreach AllMyCredits  [ ?1 ->
;          plotxy  [end_tick] of ?1  credit_now
          set credit_now credit_now - [amount] of ?1
;          plotxy  [end_tick] of ?1  credit_now
        ]
      ] [
        set credit_now sum [amount] of IBCredits
;        plotxy ticks credit_now
;        set-plot-x-range ticks ticks + 1
        set AllMyCredits  IBCredits
        set AllMyCredits  sort-on [end_tick] AllMyCredits
        foreach AllMyCredits  [ ?1 ->
;          plotxy  [end_tick] of ?1  credit_now
          set credit_now credit_now - [amount] of ?1
;          plotxy  [end_tick] of ?1  credit_now
        ]
      ]



;      set-current-plot-pen "liabilities"
;      plot-pen-reset
      ifelse Show-Individuals? = true [
        set credit_now sum [amount] of IBCredits with [borrower = BankToShowBalance]
;        plotxy ticks credit_now
;        set-plot-x-range ticks ticks + 1
        set AllMyCredits  IBCredits with [borrower = BankToShowBalance]
        set AllMyCredits  sort-on [end_tick] AllMyCredits
        foreach AllMyCredits  [ ?1 ->
;          plotxy  [end_tick] of ?1  credit_now
          set credit_now credit_now - [amount] of ?1
;          plotxy  [end_tick] of ?1  credit_now
        ]
      ] [
        set credit_now sum [amount] of IBCredits
;        plotxy ticks credit_now
;        set-plot-x-range ticks ticks + 1
        set AllMyCredits  IBCredits
        set AllMyCredits  sort-on [end_tick] AllMyCredits
        foreach AllMyCredits  [ ?1 ->
;          plotxy  [end_tick] of ?1  credit_now
          set credit_now credit_now - [amount] of ?1
;          plotxy  [end_tick] of ?1  credit_now
        ]
      ]

;      set-current-plot-pen "zero"                    ;; The x-axis
;      plot-pen-reset
;      plotxy plot-x-min 0
;      plotxy plot-x-max 0
;      set-plot-x-range ticks ticks + 2500
;      set-plot-y-range 0 plot-y-max
    ]
  ]

  if MSG-on-Bancruptcy? = TRUE [
    if count Banks with [bancrupt = TRUE] > 0 [
      set MSG-on-Bancruptcy? FALSE
      user-message (word "Bank " [who] of one-of Banks with [bancrupt = TRUE] " became insolvent")
    ]
  ]

end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                         update-demographic                                           ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;

;------------------------------------------------------------------------------------------------------;
;                                           main-procedure                                             ;
;------------------------------------------------------------------------------------------------------;
to update-demographic
  show "monthly demographic change"
  if ticks mod 12 = 0 [
    set this-year this-year + 1
    ask households [set age age + 1]]
  let months (list "JAN" "FEB" "MAR" "APR" "MAY" "JUN" "JUL" "AUG" "SEP" "OCT" "NOV" "DEC")
  let previous_month position this-month months mod 12
  set this-month item ((previous_month + 1) mod 12) months

  ask mortgages [
    set remain_tick
    remain_tick - 1
    if remain_tick < 1 [die]]

  ask jeonsejings [
    set waiting-time waiting-time + 1
    if waiting-time >= 24 [set waiting? false]]

  ask walsejings [die]

  place-mortgage
  place-jeonsejing
  place-walsejing

  set TransactionVolume_house 0
  set TransactionVolume_jeonse 0
  set TransactionVolume_walse 0

  calculate-average-price
  calculate-percentile-price
  price-per-size

  ask households with [age >= 20] [set size 1.5]
  ask households with [age < 20] [set spending 100]
  ask households with [age >= 20] [set income 1.001 * income]
  ask households with [age = 20] [set income 300 set spending 200]

  ;-----------------------------------decoration---------------------------------------;
  let EmptyString "        "
  ask patch 6.6 42 [set plabel-color red
    if price = "h-price" [set plabel (word "[HOUSE PRICE]")]
    if price = "j-price" [set plabel (word "[JEONSE PRICE]")]
    if price = "w-price" [set plabel (word "[WALSE PRICE]")]
    if price = "pps" [set plabel (word "[PRICE PER SIZE]")]]
  ask patch 8.5 41 [set plabel-color red set plabel (word " - policy rate : "policy_rate" %"(substring EmptyString 0 (6 - length (word precision policy_rate 5))))]
  ask patch 6 40 [set plabel-color red set plabel (word " - LTV : "(substring EmptyString 0 (4 - length (word precision LTV 1))) LTV" %")]
  ask patch 6 39 [set plabel-color red let jungchaek "-"
    ifelse count houses with [label = "NEW"] > 0 [set jungchaek "YES"][set jungchaek "NO"]
    set plabel (word " - supply? : "jungchaek)]
   ask patch 6 39 [set plabel-color red let jungchaek "-"
    ifelse count houses with [not member? [name] of patch-here (list "Dobong-gu" "Dongdaemun-gu" "Dongjak-gu" "Eunpyeong-gu" "Geumcheon-gu" "Guro-gu" "Gangbuk-gu" "Gangdong-gu" "Gangnam-gu"
                                                                     "Gangseo-gu" "Gwanak-gu" "Gwangjin-gu" "Jongno-gu" "Jung-gu" "Jungnang-gu" "Mapo-gu" "Nowon-gu" "Seocho-gu" "Songpa-gu"
                                                                     "Seongdong-gu" "Seodaemun-gu" "Seongbuk-gu" "Yangcheon-gu" "Yeongdeungpo-gu" "Yongsan-gu")] > 0 [set jungchaek "YES"][set jungchaek "NO"]
    set plabel (word " - supply? : "jungchaek)]

;  ask patch 41.5 38 [
;    let string "RUNNING"
;    set plabel-color red
;    let number ticks mod length string
;    set plabel (word (substring string 0 number)" "(substring string number 7))]

  ;-------------------------------------family----------------------------------------;

  foreach sort-on [who] households [?1 ->
    ask ?1 [
      set home-x [pxcor] of [patch-here] of ?1
      set home-y [pycor] of [patch-here] of ?1
    ]
  ]

  birth
  terminate
end
;------------------------------------------------------------------------------------------------------;
;                                                birth                                                 ;
;------------------------------------------------------------------------------------------------------;
to birth
 foreach sort-on [who] households [?1 ->
  ask ?1 [
  let r 0.0  let logit 0.0  let prob 0.0  set r random-float 1 let children_v 0
  ifelse count children = 0 [set children_v 0][set children_v 1]
  if age >= 20 and age <= 60  [
      set logit 2.875 + (-0.155 * age) + (-0.264 * children_v)
      set prob 1 / (1 + e ^ (-(logit)))  set prob prob * birth_rate]
  if r < prob [
     hatch-households 1 [
     set mememe self
     set shape "person" set size 1.5 set color black
     set age 0 set home-x [pxcor] of [patch-here] of ?1 set home-y [pycor] of [patch-here] of ?1

  ;-------------------------------------assign-bank----------------------------------------;
     let NumberOfBanks (count Banks)
     set myBank_dep random NumberOfBanks
     ifelse true [
      set myBank_dep random count Banks
      set myBank_loan myBank_dep + 1 + (random (count Banks - 1))
      if myBank_loan >= count Banks [set myBank_loan myBank_loan - count Banks]
      if myBank_dep = myBank_loan [user-message (word "Error: myBank_dep = myBank_loan,  Bank No.: " myBank_dep)]
    ] [
      let prob_loan n-values (count Banks) [0]
      let prob_dep n-values (count Banks) [0]
      let Counter 0
      while [Counter < count Banks] [  ; a loop through all banks
        set prob_loan replace-item Counter prob_loan (count Households with [myBank_loan = Counter])
        set prob_dep replace-item Counter prob_dep (count Households with [myBank_dep = Counter])
        set Counter Counter + 1
      ]
      set myBank_loan position (min prob_loan) prob_loan
      set myBank_dep position (min prob_dep) prob_dep
      if myBank_loan = myBank_dep [
        set myBank_dep myBank_dep + 1
        if myBank_dep >= count Banks [
          set myBank_dep myBank_dep - count Banks
        ]
      ]
    ]
  ;-----------------------------------------------------------------------------------------;
     ]
     ask houses with [which-occupied? = ?1][set which-occupied? (turtle-set ?1 mememe)]
     ask ?1 [set children (turtle-set mememe children)]]
   ]
  ]
end

  ;------------------------------------------death--------------------------------------------;
to terminate
  ask households [
  let r 0.0   let prob 0.0 set r random-float 1
  if age <= 40 [set prob 0.000411]
  if age > 40 [set prob 0.0001 * e ^ (0.1017 * age)]
  if prob > 0.5 [set prob 0.5]  set prob prob * mortality_rate
   if r < prob [bequest self families self die
      ask [own-mortgage] of self [die]
      ask [own-jeonsejing] of self [die]
      ask [own-walsejing] of self [die]]
  ]
end

to bequest [x y]
  if count other families x != 0 [
  let cash_to_transfer [cash] of x / (count other families x)
  let deposit_to_transfer [deposits] of x / (count other families x)
  ask other families x [
    set cash cash + cash_to_transfer
    set deposits deposits + deposit_to_transfer]
  if count own-house != 0 [
    let besquest_house [own-house] of x
    ask min-one-of other families x [who] [set own-house (turtle-set besquest_house own-house)]]]
end

;------------------------------------------------------------------------------------------------------;
;                                           fill-the-patch                                             ;
;------------------------------------------------------------------------------------------------------;
to fill-the-patch
  ask houses[
  if price = "h-price" [
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Dobong-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Dobong-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Dongdaemun-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Dongdaemun-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Dongjak-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Dongjak-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Eunpyeong-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Eunpyeong-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Geumcheon-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Geumcheon-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Guro-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Guro-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Gangbuk-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Gangbuk-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Gangdong-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Gangdong-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Gangnam-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Gangnam-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Gangseo-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Gangseo-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Gwanak-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Gwanak-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Gwangjin-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Gwangjin-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Jongno-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Jongno-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Jung-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Jung-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Jungnang-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Jungnang-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Mapo-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Mapo-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Nowon-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Nowon-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Seocho-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Seocho-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Songpa-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Songpa-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Seongdong-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Seongdong-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Seodaemun-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Seodaemun-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Seongbuk-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Seongbuk-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Yangcheon-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Yangcheon-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Yeongdeungpo-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Yeongdeungpo-gu 1
  gis:set-drawing-color scale-color green mean [h-price] of houses with [[name] of patch-here = "Yongsan-gu"] (average-house-price - 2.56 * standard-deviation [h-price] of houses) (average-house-price + 2.56 * standard-deviation [h-price] of houses) gis:fill Yongsan-gu 1
  gis:set-drawing-color gray - 3
  gis:draw seoul-dataset 0.5
  ]
  if price = "j-price" [
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Dobong-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Dobong-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Dongdaemun-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Dongdaemun-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Dongjak-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Dongjak-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Eunpyeong-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Eunpyeong-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Geumcheon-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Geumcheon-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Guro-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Guro-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Gangbuk-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Gangbuk-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Gangdong-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Gangdong-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Gangnam-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Gangnam-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Gangseo-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Gangseo-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Gwanak-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Gwanak-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Gwangjin-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Gwangjin-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Jongno-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Jongno-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Jung-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Jung-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Jungnang-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Jungnang-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Mapo-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Mapo-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Nowon-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Nowon-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Seocho-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Seocho-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Songpa-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Songpa-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Seongdong-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Seongdong-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Seodaemun-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Seodaemun-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Seongbuk-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Seongbuk-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Yangcheon-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Yangcheon-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Yeongdeungpo-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Yeongdeungpo-gu 1
  gis:set-drawing-color scale-color green mean [j-price] of houses with [[name] of patch-here = "Yongsan-gu"] (average-jeonse-price - 2.56 * standard-deviation [j-price] of houses) (average-jeonse-price + 2.56 * standard-deviation [j-price] of houses) gis:fill Yongsan-gu 1
  gis:set-drawing-color gray - 3
  gis:draw seoul-dataset 0.5
  ]
  if price = "w-price" [
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Dobong-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Dobong-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Dongdaemun-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Dongdaemun-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Dongjak-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Dongjak-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Eunpyeong-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Eunpyeong-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Geumcheon-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Geumcheon-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Guro-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Guro-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Gangbuk-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Gangbuk-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Gangdong-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Gangdong-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Gangnam-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Gangnam-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Gangseo-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Gangseo-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Gwanak-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Gwanak-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Gwangjin-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Gwangjin-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Jongno-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Jongno-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Jung-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Jung-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Jungnang-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Jungnang-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Mapo-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Mapo-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Nowon-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Nowon-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Seocho-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Seocho-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Songpa-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Songpa-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Seongdong-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Seongdong-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Seodaemun-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Seodaemun-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Seongbuk-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Seongbuk-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Yangcheon-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Yangcheon-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Yeongdeungpo-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Yeongdeungpo-gu 1
  gis:set-drawing-color scale-color green mean [w-price] of houses with [[name] of patch-here = "Yongsan-gu"] (average-walse-price - 2.56 * standard-deviation [w-price] of houses) (average-walse-price + 2.56 * standard-deviation [w-price] of houses) gis:fill Yongsan-gu 1
  gis:set-drawing-color gray - 3
  gis:draw seoul-dataset 0.5
  ]
  if price = "pps" [
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Dobong-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Dobong-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Dongdaemun-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Dongdaemun-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Dongjak-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Dongjak-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Eunpyeong-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Eunpyeong-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Geumcheon-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Geumcheon-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Guro-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Guro-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Gangbuk-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Gangbuk-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Gangdong-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Gangdong-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Gangnam-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Gangnam-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Gangseo-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Gangseo-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Gwanak-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Gwanak-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Gwangjin-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Gwangjin-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Jongno-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Jongno-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Jung-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Jung-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Jungnang-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Jungnang-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Mapo-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Mapo-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Nowon-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Nowon-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Seocho-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Seocho-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Songpa-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Songpa-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Seongdong-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Seongdong-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Seodaemun-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Seodaemun-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Seongbuk-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Seongbuk-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Yangcheon-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Yangcheon-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Yeongdeungpo-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Yeongdeungpo-gu 1
  gis:set-drawing-color scale-color green mean [pps] of houses with [[name] of patch-here = "Yongsan-gu"] (mean [pps] of houses - 2.56 * standard-deviation [pps] of houses) (mean [pps] of houses + 2.56 * standard-deviation [pps] of houses) gis:fill Yongsan-gu 1
  gis:set-drawing-color gray - 3
  gis:draw seoul-dataset 0.5
  ]
 ]
end

;------------------------------------------------------------------------------------------------------;
;                                                                                                      ;
;                                           to-report                                                  ;
;                                                                                                      ;
;------------------------------------------------------------------------------------------------------;
  ;----------------------------------------basics-----------------------------------------------;
to-report making-electorate
  let electorate []
  foreach [who] of households [?1 ->
    let electorate_tmp min-one-of families household ?1 [who]
    set electorate fput electorate_tmp electorate]
  set electorate turtle-set remove-duplicates electorate
  report electorate
end

to-report families [x]
  ifelse x != nobody [
    report turtle-set households with [home-x = [home-x] of x and home-y = [home-y] of x]][report x]
end

  ;------------------------------------making-whoofhouse----------------------------------------;
  ;------------------------------------making-whoofhouse----------------------------------------;
to-report making-whoofhouse [x]
  let walsehouse nobody
  let jeonsehouse nobody
  let binhouse nobody
  let jagijib nobody
  foreach sort-on [who] [own-house] of x [?1 ->
    if not [occupied?] of ?1 [
      if [home-status] of [which-occupied?] of ?1 = "walse" [set walsehouse (turtle-set ?1 walsehouse)]
      if [home-status] of [which-occupied?] of ?1 = "jeonse" and not item 0 giver x [set jeonsehouse (turtle-set ?1 jeonsehouse)]]]
  set binhouse turtle-set ([own-house] of x) with [not occupied?]

   ;-----------------------------------------jagijib----------------------------------------------;
  set jagijib turtle-set ([own-house] of x) with [which-occupied? = x]
  report (turtle-set walsehouse jeonsehouse binhouse jagijib)
end

  ;----------------------------------------average-price------------------------------------------;
to calculate-average-price
   set average-house-price mean [h-price] of houses with [h-price != 0]
   set average-jeonse-price mean [j-price] of houses with [j-price != 0]
   set average-walse-price mean [w-price] of houses with [w-price != 0]

  let house_obj houses with [[name] of patch-here = "Gangnam-gu" or
    [name] of patch-here = "Seocho-gu" or
    [name] of patch-here = "Songpa-gu" or
    [name] of patch-here = "Gangdong-gu"]
  set average-gangnam-price mean [h-price] of house_obj with [h-price != 0]

  let house_obj2 houses with [[name] of patch-here != "Gangnam-gu" and
    [name] of patch-here != "Seocho-gu" and
    [name] of patch-here != "Songpa-gu" ;and
    ;[name] of patch-here != "Gangdong-gu"
  ]
  set average-non-price mean [h-price] of house_obj2 with [h-price != 0]
end

to calculate-percentile-price
   set house-price-25 stats:quantile w "house-price" 25
   set house-price-75 stats:quantile w "house-price" 75
end

  ;-------------------------------------mortgage-payment---------------------------------------;
to-report mortgage-payment [x]
  let mortgage_payment 0
  ask mortgages with [which-owner = x][
    set mortgage_payment PurchasePrice * ([lending_rate] of bank [myBank_loan] of x ^ 180 - 1) / ([lending_rate] of bank [myBank_loan] of x - 1)]
  report mortgage_payment
end

  ;------------------------------------interest-earnings---------------------------------------;
to-report interest-earnings [x]
  let interest_earnings [deposits] of x * [deposit_rate] of bank [myBank_dep] of x
  report interest_earnings
end

  ;-----------------------------------------gohayng--------------------------------------------;
to-report gohyang [x]
  let gohyangjib one-of houses with [which-occupied? = x]
  report gohyangjib
end

  ;-------------------------------------receiver & giver----------------------------------------;
to-report receiver [x]
  let result (list true 0)
  if [waiting?] of jeonsejings with [seibja = x] = false [
    set result (list false [purchasePrice] of jeonsejings with [seibja = x])]
  report result
end

to-report giver [x]
  let result (list true 0)
  if [waiting?] of jeonsejings with [jibjuin = x] = false [
    set result (list false [purchasePrice] of jeonsejings with [seibja = x])]
  report result
end

  ;----------------------------------------h-price-per-size---------------------------------------;
to price-per-size
  foreach sort-on [who] houses [?1 ->
    ask ?1 [
    set pps [h-price] of ?1 / [h-size] of ?1
    ]
  ]
end
;------------------------------------------------------------------------------------------------------;
;                                             placement                                                ;
;------------------------------------------------------------------------------------------------------;
to place-bank
   let groupbank sort-on [who] banks
   let Howmanybank length groupbank
   let an 0 let side sqrt Howmanybank
   let stepx 11 let stepy 2.2 let x 11  let y 1.2
   while [an < Howmanybank][if x > 11 + (side - 1) * stepx [set y y + stepy set x 11]
   ask item an groupbank [setxy x y] set x x + stepx set an an + 1]
end

to place-exhouse
   let newly-build houses with [label = "NEW"]
   let newly-builds sort-on [who] newly-build
   let Howmanybuilds length newly-builds
   let an 0  let side sqrt Howmanybuilds
   let step 2.2 let x 18  let y 37.5
   while [an < Howmanybuilds][if x > (side - 1) * step [set y y - step set x 0.2]
   ask item an newly-builds [setxy x y] set x x + step set an an + 1]
end

to place-bidder
  if bidder != nobody [
   set bidders sort-on [who] bidder
   let Howmanybidders length bidders
   let an 0  let side sqrt Howmanybidders
   let step 2.2 let x 0.2  let y 20
   while [an < Howmanybidders][if x > (side - 1) * step [set y y + step set x 0.2]
   ask item an bidders [setxy x y] set x x + step set an an + 1]]
end

to place-auctioneer
  if auctioneer != nobody [
   set auctioneers sort-on [who] auctioneer
   let Howmanyauctioneers length auctioneers
   let an 0  let side sqrt Howmanyauctioneers
   let step 2.2 let x 41.5  let y 1
   while [an < Howmanyauctioneers][if x < (side - 1) * step [set y y + step set x 41.5]
   ask item an auctioneers [setxy x y] set x x - step set an an + 1]]
end

to place-evicted
  if evicted != nobody [
   set evicteds sort-on [who] evicted
   let Howmanyevicted length evicteds
   let an 0 let side sqrt Howmanyevicted
   let step 2.2 let x 41.5  let y 41.5
   while [an < Howmanyevicted][if x < (side - 1) * step [set y y - step set x 41.5]
   ask item an evicteds [setxy x y] set x x - step set an an + 1]]
end

to place-mortgage
  if mortgages != nobody [
   let mortgageses sort-on [who] mortgages
   let Howmanymortgages length mortgageses
   let an 0  let side 35.6
   let step 0.5 let x 1.5  let y 1.2
   while [an < Howmanymortgages][if y > side [set x x + step set y 1.2]
   ask item an mortgageses [setxy x y] set y y + step set an an + 1]]
end

to place-jeonsejing
  if jeonsejings != nobody [
   let jeonsejingses sort-on [who] jeonsejings
   let Howmanyjeonsejings length jeonsejingses
   let an 0  let side 35.6
   let step 0.5 let x 4  let y 1.2
   while [an < Howmanyjeonsejings][if y > side [set x x + step set y 1.2]
   ask item an jeonsejingses [setxy x y] set y y + step set an an + 1]]
end

to place-walsejing
  if walsejings != nobody [
   let walsejingses sort-on [who] walsejings
   let Howmanywalsejings length walsejingses
   let an 0  let side 35.6
   let step 0.5 let x 6.5  let y 1.2
   while [an < Howmanywalsejings][if y > side [set x x + step set y 1.2]
   ask item an walsejingses [setxy x y] set y y + step set an an + 1]]
end

to moving-family
  foreach sort-on [who] households with [color = yellow][?1 ->
    ask families ?1 [move-to ?1]]
  foreach sort-on [who] households with [color = green][?2 ->
    ask families ?2 [move-to ?2]]
  foreach sort-on [who] households with [color = pink][?3 ->
    ask families ?3 [move-to ?3]]
end
@#$#@#$#@
GRAPHICS-WINDOW
175
20
667
513
-1
-1
11.0
1
10
1
1
1
0
1
1
1
0
43
0
43
1
1
1
ticks
30.0

SLIDER
1660
495
1760
528
gamma
gamma
0
1
0.95
0.01
1
NIL
HORIZONTAL

BUTTON
10
20
163
53
NIL
setup
NIL
1
T
OBSERVER
NIL
\
NIL
NIL
1

PLOT
1560
10
1755
130
M0
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"M0" 1.0 0 -16777216 true "" "plot (sum [cash] of households + sum [cash] of Banks + sum [Reserve] of Banks) / 10000"
"Reserve" 1.0 0 -2674135 true "" "plot sum [Reserve] of Banks"
"Cash" 1.0 0 -13345367 true "" "plot (sum [cash] of households + sum [cash] of Banks) / 10000"

SLIDER
1114
437
1283
470
birth_rate
birth_rate
0
2
0.0
0.01
1
%
HORIZONTAL

SLIDER
1113
397
1284
430
mortality_rate
mortality_rate
0
2
0.0
0.01
1
%
HORIZONTAL

CHOOSER
10
140
162
185
price
price
"h-price" "j-price" "w-price" "pps"
0

MONITOR
685
395
765
440
DATE
(word this-year \" \" this-month)
0
1
11

SWITCH
1660
425
1760
458
show-money?
show-money?
0
1
-1000

BUTTON
1478
396
1646
511
do multi-helikopter
Multi-Helikopter
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1660
460
1760
493
Random-Transactions?
Random-Transactions?
0
1
-1000

SWITCH
1660
390
1760
423
Interbank-Market?
Interbank-Market?
0
1
-1000

SWITCH
1660
215
1760
248
Bank-Runs?
Bank-Runs?
1
1
-1000

SWITCH
1660
355
1760
388
Demographics
Demographics
1
1
-1000

OUTPUT
685
168
1649
388
11

CHOOSER
742
134
963
179
BankToShowBalance
BankToShowBalance
0 1 2 3 4 5 6 7 8
6

CHOOSER
1040
135
1265
180
HouseholdToShowBalance
HouseholdToShowBalance
9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
17

SLIDER
931
396
1103
429
policy_rate
policy_rate
0
5
1.5
0.25
1
%
HORIZONTAL

PLOT
1340
10
1555
130
M1
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"M1" 1.0 0 -16777216 true "" "plot M1"
"Deposits" 1.0 0 -2674135 true "" "plot sum [deposits] of households"
"Cash" 1.0 0 -13345367 true "" "plot sum [cash] of households + sum [cash] of Banks"

SLIDER
933
479
1103
512
LTV
LTV
10
100
20.0
0.1
1
%
HORIZONTAL

SWITCH
1660
250
1760
283
Show-Balance-Sheets?
Show-Balance-Sheets?
0
1
-1000

SWITCH
1660
285
1760
318
Show-Individuals?
Show-Individuals?
0
1
-1000

SWITCH
1660
320
1760
353
MSG-on-Bancruptcy?
MSG-on-Bancruptcy?
1
1
-1000

SLIDER
1112
479
1284
512
cash-ratio
cash-ratio
0
100
10.0
0.01
1
%
HORIZONTAL

PLOT
1010
10
1170
130
walse-price
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"walse" 1.0 0 -16777216 true "" "plot average-walse-price"

SLIDER
1295
395
1467
428
tau
tau
0
100
24.0
1
1
ticks
HORIZONTAL

PLOT
1175
10
1335
130
gangnam
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"gangnam" 1.0 0 -16777216 true "" "plot average-gangnam-price"
"non-gn" 1.0 0 -2674135 true "" "plot average-non-price"

MONITOR
15
470
65
515
house
TransactionVolume_house
0
1
11

MONITOR
65
470
115
515
jeonse
TransactionVolume_jeonse
0
1
11

MONITOR
115
470
165
515
walse
TransactionVolume_walse
0
1
11

CHOOSER
10
240
160
285
placement
placement
"random" "center"
1

SLIDER
1295
435
1470
468
fundamental_ratio
fundamental_ratio
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
1660
530
1760
563
interest_margin
interest_margin
10
20
12.5
0.1
1
%
HORIZONTAL

SLIDER
1296
477
1468
510
max_numbid
max_numbid
1
100
20.0
1
1
trial
HORIZONTAL

BUTTON
10
60
162
135
go
total
NIL
1
T
OBSERVER
NIL
=
NIL
NIL
1

TEXTBOX
16
451
166
469
Trade Volume
12
31.0
1

MONITOR
10
345
160
390
fundemental_pe
p_t
0
1
11

MONITOR
10
395
160
440
speculator_pe
u_t
0
1
11

BUTTON
775
450
920
510
NIL
build-exthouse
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
690
450
770
501
  [CAUTION]\nNOT DURING \n     AUCTION
12
15.0
1

MONITOR
777
395
922
444
Now
(word substring date-and-time 22 26\"-0\"substring date-and-time 19 20\"-\"substring date-and-time 16 18\"  \"substring date-and-time 0 5)
0
1
12

BUTTON
845
640
995
760
NIL
export
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1385
520
1445
565
Multiplier
(1 - reserve-ratio) / (reserve-ratio + cash-ratio)
4
1
11

MONITOR
1450
520
1535
565
Credits to HH
Aggr_CreditsToHH
0
1
11

MONITOR
1540
520
1645
565
Interbank Credit
Sum_Interbank_Credits
0
1
11

CHOOSER
10
190
160
235
data
data
"data1.prn" "data2.prn" "data3.prn" "data4.prn" "data5.prn" "data6.prn" "data7.prn" "data8.prn" "data9.prn" "data10.prn" "data11.prn" "data12.prn" "data13.prn" "data14.prn" "data15.prn" "data16.prn" "data17.prn" "data18.prn" "data19.prn" "data20.prn"
8

CHOOSER
10
290
160
335
where_you_at
where_you_at
"office" "home"
1

PLOT
845
10
1005
130
jeonse-price
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-jeonse-price"

PLOT
680
10
840
130
house-price
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot average-house-price"

MONITOR
115
520
165
565
bidder
count bidder
0
1
11

MONITOR
165
520
230
565
auctioneer
count auctioneer
0
1
11

MONITOR
15
520
117
565
auction_name
choice
17
1
11

MONITOR
230
520
292
565
Pricebid
Pricebid
0
1
11

MONITOR
305
520
362
565
h_buy
count households with [auction_name = \"buyer\"]
0
1
11

MONITOR
360
520
417
565
h_sell
count households with [auction_name2 = \"seller\"]
0
1
11

MONITOR
430
520
487
565
j_buy
count households with [auction_name = \"jeonse\"]
0
1
11

MONITOR
485
520
545
565
j_sell
count households with [auction_name2 = \"jeonse\"]
0
1
11

MONITOR
555
520
612
565
w_buy
count households with [auction_name = \"walse\"]
0
1
11

MONITOR
610
520
667
565
w_sell
count households with [auction_name2 = \"walse\"]
0
1
11

MONITOR
685
520
742
565
jaga
count households with [home-status = \"jaga\"]
17
1
11

MONITOR
742
520
797
565
jeonse
count households with [home-status = \"jeonse\"]
17
1
11

MONITOR
795
520
852
565
walse
count households with [home-status = \"walse\"]
17
1
11

MONITOR
1210
520
1267
565
ave.m
count mortgages / count households
3
1
11

MONITOR
1265
520
1322
565
ave.j
count jeonsejings / count households
3
1
11

MONITOR
1320
520
1377
565
ave.w
count walsejings / count households
3
1
11

MONITOR
860
520
917
565
h-price
average-house-price
0
1
11

MONITOR
915
520
972
565
j-price
average-jeonse-price
0
1
11

MONITOR
970
520
1032
565
w-price
average-walse-price
0
1
11

MONITOR
1040
520
1112
565
gangnam
average-gangnam-price
0
1
11

MONITOR
1110
520
1200
565
non-gangnam
average-non-price
0
1
11

TEXTBOX
1660
175
1745
201
MADE BY \nHANNAH LEE
12
0.0
1

MONITOR
15
590
72
635
ave.l_r
sum [lending_rate] of banks / count banks
3
1
11

MONITOR
70
590
127
635
ave.d_r
sum [deposit_rate] of banks / count banks
3
1
11

MONITOR
135
590
192
635
BA_0
count banks with [BA_mode = 0]
0
1
11

MONITOR
190
590
247
635
BA_1
count banks with [BA_mode = 1]
0
1
11

MONITOR
245
590
302
635
BA_2
count banks with [BA_mode = 2]
0
1
11

MONITOR
300
590
357
635
BA_3
count banks with [BA_mode = 3]
0
1
11

MONITOR
365
590
427
635
gagusu
count households / count making-electorate
3
1
11

MONITOR
435
590
490
635
mode_0
count households with [mode = 0]
0
1
11

MONITOR
490
590
552
635
mode_1
count households with [mode = 1]
0
1
11

MONITOR
550
590
612
635
mode_2
count households with [mode = 2]
0
1
11

MONITOR
610
590
672
635
mode_3
count households with [mode = 3]
0
1
11

MONITOR
670
590
732
635
mode_4
count households with [mode = 4]
0
1
11

MONITOR
730
590
792
635
mode_5
count households with [mode = 5]
0
1
11

MONITOR
800
590
870
635
pps
mean [pps] of houses
3
1
11

MONITOR
870
590
927
635
waiting
count daegisuyo
0
1
11

PLOT
10
640
170
760
pps
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 0 [plot mean [pps] of houses]"
"pen-1" 1.0 0 -2674135 true "" "if ticks > 0 [plot mean [pps] of houses with [member? patch-here \n(patch-set (patches gis:intersecting Gangnam-gu) \n           (patches gis:intersecting Seocho-gu)\n           (patches gis:intersecting Songpa-gu))]]"
"pen-2" 1.0 0 -13345367 true "" "if ticks > 0 [plot mean [pps] of houses with [not member? patch-here\n(patch-set (patches gis:intersecting Gangnam-gu)\n            (patches gis:intersecting Seocho-gu)\n            (patches gis:intersecting Songpa-gu))]]"

SLIDER
930
435
1102
468
reserve-ratio
reserve-ratio
0
1
0.03
0.01
1
NIL
HORIZONTAL

PLOT
180
640
340
760
interest rate
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks > 0 [plot mean [lending_rate] of banks]"
"pen-1" 1.0 0 -2674135 true "" "if ticks > 0 [plot mean [deposit_rate] of banks]"

PLOT
345
640
505
760
Credits
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot Aggr_CreditsToHH"

PLOT
510
640
670
760
mortgage
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count mortgages"
"pen-1" 1.0 0 -2674135 true "" "plot count jeonsejings"

PLOT
675
640
835
760
fundamental
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot f_t"
"pen-1" 1.0 0 -2674135 true "" "plot u_t"

@#$#@#$#@
## WHAT IS IT?

This is about how the house,jeonse or walse prices move according to policy variables

## HOW IT WORKS

1. People maximizes utility given policy variable and decide what to buy or sell
2. They approach to the targeted house, and auction it
3. If they lack money borrowed from bank, otherwise deposits

## HOW TO USE IT

First press setup button and then go

## THINGS TO NOTICE

Policy rate or LTV are useless in controlling the price

## THINGS TO TRY

policy-rate, LTV, building extra houses, setting horizon etc.

## EXTENDING THE MODEL

It would be nice if price would volatile a bit more

## NETLOGO FEATURES

None

## RELATED MODELS

Matthias Lengnick's MoneCreation.nlogo

## CREDITS AND REFERENCES

https://ace-teaching.000webhostapp.com
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

fire2
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hexagonal prism
false
0
Rectangle -7500403 true true 90 90 210 270
Polygon -1 true false 210 270 255 240 255 60 210 90
Polygon -13345367 true false 90 90 45 60 45 240 90 270
Polygon -11221820 true false 45 60 90 30 210 30 255 60 210 90 90 90

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
7
Line -7500403 false 30 105 270 105
Line -7500403 false 270 105 285 90
Line -7500403 false 15 210 30 195
Line -7500403 false 30 195 270 195
Line -7500403 false 270 105 270 195
Line -7500403 false 270 195 285 210
Line -7500403 false 15 90 30 105
Line -7500403 false 30 105 30 195
Line -7500403 false 15 90 15 210
Line -7500403 false 15 210 285 210
Line -7500403 false 15 90 285 90
Line -7500403 false 285 90 285 210
Rectangle -7500403 true false 30 105 270 195

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
setup
total
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
