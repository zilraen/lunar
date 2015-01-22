%%HP: T(0)A(D)F(.);

«
  PUSH
  DEG

  «
    CLLCD
    { {} {} {} {} {} {"Next" « » } } TMENU
    "Lunar ship simulator" 1 DISP
    FONT\->
    FONT6 \->FONT
    "v.1.1" 3 DISP
    "(c) 1985" 3 DISP
    "  Mikhail PUKHOV, USSR" 4 DISP
    "(c) 2011" 5 DISP
    "  Serguei TARASSOV" 6 DISP
    "  pmk.arbinada.com" 7 DISP
    "  st@arbinada.com" 8 DISP
    "This software is" 10 DISP
    "under GNU GPL" 11 DISP
    \->FONT
    -1 WAIT DROP
    CLLCD
    "Keyboard shortcuts" 1 DISP
    FONT\->
    FONT7 \->FONT
    "\|^\|v: acceleration" 3 DISP
    "\<-\->: ship rotation" 4 DISP
    "1 2 3: set \GDt 1/10/100" 5 DISP
    "F1: switch \GD\Ga 10/1°" 6 DISP
    "F2: switch \GDa 1/0.5" 7 DISP
    "F6: stop acceleration" 8 DISP
    "J: orbital view/pause" 9 DISP
    "N: restart Q: quit" 10 DISP
    \->FONT
    -1 WAIT DROP
  » 'showhelp' STO

  @
  @ Parameters
  @
  1.62  'g'     STO @ Lunar acceleration of gravity on surface, m/sec2
  1738000. 'rp' STO @ Radius of planet, m
  0.
  29.4  'alim'  STO @ Acceleration limit, m/sec2
  3660. 'c'     STO @ Nozzle flow, m/sec
  4500. 'mf'    STO @ Fuel mass in kg
  mf    'mfn1'  STO
  2250. 'ms'    STO @ Ship mass w/o fuel
  1.    'dt'    STO @ Maneuver discrete time in sec
  @ Initial screen scale
  0.     'ymin0' STO
  1000.  'ymax0' STO
  -1500. 'xmin0' STO
  1500.  'xmax0' STO

  @ Initialisation every flight parameters
  «
    0.    'a'     STO @ Current acceleration
    0.    'an1'   STO @ Acceleration N-1 (previous step)
    1.    'da'    STO @ Acceleration increment
    0.    'ac'    STO @ angle of climb in degrees
    0.    'acn1'  STO
    10.   'dac'   STO @ Angle increment
    1.    'dacn1' STO
    0.    'u'     STO @ vertical velocity
    0.    'un1'   STO
    0.    'v'     STO @ horisontal velosity
    0.    'vn1'   STO
    0.    'h'     STO @ Current altitude
    h     'hn1'   STO
    0.    'phi'   STO @ Initial angle
    phi   'phin1' STO
    rp    'r'     STO @ Initial orbit altitude
    r     'rn1'   STO
    r     'rmax'  STO
    0.    'x'     STO @ Current coord X
    x     'xn1'   STO
    0.    'l'     STO @ Traversed distance
    l     'ln1'   STO
    3600. 4 *
          'ls'    STO @ Life support in sec
    ls    'lsn1'  STO
    {}    'orbit' STO @ Orbit coordinates list
    @ Temporary values
    0. 'q'   STO
    0. 't'   STO
    0. 'dmf' STO
    @ Screen scale
    ymin0 'ymin' STO
    ymax0 'ymax' STO
    xmin0 'xmin' STO
    xmax0 'xmax' STO
    @ Flags
    0 'started' STO
    0 'landing' STO
  » 'paramsinit' STO

  paramsinit

  @ Global application flags
  0 'tostop'  STO
  1 'toinit'  STO
  1 'newgame' STO
  1 'showdist' STO

  @ Cleanup procedure
  «
    {
      'g', 'rp',
      'a', 'an1', 'da', 'alim',
      'ac', 'acn1', 'dac', 'dacn1',
      'c',
      'v', 'vn1',
      'u', 'un1',
      'h', 'hn1',
      'x', 'xn1',
      'l', 'ln1',
      'r', 'rn1', 'rmax',
      'phi', 'phin1',
      'ls', 'lsn1',
      'mf', 'dmf', 'mfn1', 'ms',
      'orbit',
      'dt',
      't', 'q',
      'started', 'landing',
      'tostop', 'toinit', 'newgame', 'showdist',
      'xmin', 'xmax', 'ymin', 'ymax',
      'xmin0', 'xmax0', 'ymin0', 'ymax0',
      'showrepl', 'showgxor', 'getpoint', 'showship',
      'showorbit1', 'showorbit2', 'orbitaddpoint',
      'paramsinput', 'paramsinit',
      'calcmaneuver', 'cleanup', 'showhelp',
      'debugout',
      'PPAR'
    } PURGE
    POP
  » 'cleanup' STO

  @ Ask for initial parameters
  «
    CLLCD
    "Lunar ship"
    {
      {"g " "Gravity acceler.on surface, m/s2" 0}
      {"R " "Planet radus, m" 0}
      {"c " "Nozzle flow, m/sec" 0}
      {"LS" "Life support, sec" 0}
      {"A " "Acceleration limit, m/s2" 0}
      {"Ms" "Ship mass w/o fuel, kg" 0}
      {"Mf" "Fuel mass, kg" 0}
      {"L/X" "Show 1 - distance; 0 - coord, m" 0}
    }
    {2 1}
    g rp c ls alim ms mf showdist
    8 \->LIST
    g rp c ls alim ms mf showdist
    8 \->LIST
    IF INFORM
    THEN
      OBJ\->
      DROP
      ABS SIGN 'showdist' STO
      'mf'   STO
      'ms'   STO
      'alim' STO
      'ls'   STO
      'c'    STO
      'rp'   STO
      'g'    STO
    ELSE
      cleanup
      HALT
    END
  » 'paramsinput' STO

  @ Application const
  0.3 @ delay in sec between iterations
      @ can be modifed [0.1, 0.8] depending on calc speed
  131 80
  20 20 10 12 11 8 4
  #8d #32d #2d #5d
  4 @ 360 should divide it without reminder
  \-> stepdelay
      dispwidth dispheight
      alpha1 alpha2 r1 r2 r3 r4 r5
      lunx luny lunr shipr
      deginc
  «
  
    «
      \-> val line
      «
        dispheight 2 / R\->B
        15 line 7 * + R\->B
        2 \->LIST
        val
        showrepl
      »
    » 'debugout' STO

    «
      1 \->GROB PICT UNROT REPL
    » 'showrepl' STO

    «
      \-> valn1 valn coord toinit
      «
        IF toinit valn1 valn \=/ OR
        THEN
          IF toinit NOT
          THEN
            PICT coord valn1 1 \->GROB GXOR
          END
          PICT coord valn 1 \->GROB GXOR
        END
      »
    » 'showgxor' STO

    «
      \-> x0 y0 r phi
      «
        r phi COS * x0 + R\->B
        y0 r phi SIN * - R\->B
        2 \->LIST
      »
    » 'getpoint' STO

    «
      \-> xn1 hn1 x h phi
      «
        @ Trajectory
        xn1 hn1 R\->C x h R\->C LINE
        @ Ship
        x h R\->C C\->PX LIST\-> DROP B\->R
        DUP IP
        IF dispheight 5 - \>=
        THEN
          DROP dispheight 5 -
        END
        SWAP B\->R
        \-> y0 x0
        «
          x0 y0
          x0 y0 r1 180 alpha1 - phi -
          getpoint
          x0 y0 r1 alpha1 phi -
          getpoint
          x0 y0 r3 0 phi -
          getpoint
          x0 y0 r2 alpha2 NEG phi -
          getpoint
          x0 y0 r2 180 alpha2 + phi -
          getpoint
          x0 y0 r3 180 phi -
          getpoint
          x0 y0 r4 90 phi -
          getpoint
          x0 y0 r5 270 phi -
          getpoint
          \-> p1 p2 p3 p4 p5 p6 p7 p8
          «
            p1 p2 TLINE
            p2 p3 TLINE
            p3 p4 TLINE
            p3 p6 TLINE
            p5 p6 TLINE
            p1 p6 TLINE
            p1 p7 TLINE
            p2 p7 TLINE
            x0 R\->B y0 R\->B 2 \->LIST p8 TLINE
          »
          DROP2
        »
      »
    » 'showship' STO
    
    @ Calculate maneuver
    «
      a ms mf + * t * c / DUP 'dmf' STO
      IF mf >
      THEN
        mf DUP 'dmf' STO
        0 'mf' STO
        c * ms mf + t * /
      ELSE
        mf dmf - 'mf' STO
        a
      END
      \-> ai
      «
        DO
          ai ac COS * rp r / SQ g * - v SQ r / +
          ai ac SIN * u v * r / -
          \-> air aix
          «
            IF started NOT air 0 > AND
            THEN
              1 'started' STO
            END
            IF started landing NOT AND
            THEN
              r
              u DUP air t * + DUP 'u' STO
              + 2 / t * + 'r' STO
              v DUP aix t * + DUP 'v' STO
              + 2 / t * DUP l + 'l' STO
              90 * \pi \->NUM r * / phi + DUP 'phi' STO
              2 \pi \->NUM * r * * 360 / 'x' STO
              r rp - DUP 'h' STO
              IF 0 <
              THEN
                h t * ABS 2 h * / 't' STO
              END
            END
          »
        UNTIL
          h -0.01 \>=
        END
        r rp - ABS
        IF 0.01 <
        THEN
          rp 'r' STO
          0 'h' STO
          IF started
          THEN
            1 'landing' STO
          END
        END
      »
    » 'calcmaneuver' STO
    
    @ Small view of planet and orbit
    «
      \-> phin1 phi toinit
      «
        IF toinit
        THEN
          lunx luny 2 \->LIST lunr 0 360 ARC
          xmin 0 R\->C xmax 0 R\->C LINE @ Lune surface
          lunx luny 2 \->LIST shipr 0 phi IP
          IF v 0 > THEN NEG SWAP END
          ARC
        END
        phi IP deginc MOD
        IF 0 ==
        THEN
          lunx luny 2 \->LIST shipr 0 phi IP
          IF v 0 > THEN NEG SWAP END
          ARC
        END
      »
    » 'showorbit1' STO
    
    @ Show orbit in detailed view
    «
@      {
@        (1738000., 0)
@        (1785000., 5)
@        (1790000., 10)
@        (1800000., 15)
@        (1900000., 25)
@        (1950000., 45)
@      } 'orbit' STO
      rp rmax MAX 'rmax' STO
      rp 1000 / IP DUP
      rmax rp / * IP
      DUP dispwidth dispheight / * IP
      \-> rpkm maxcoordy maxcoordx
      «
        maxcoordx NEG maxcoordx XRNG
        maxcoordy NEG maxcoordy YRNG
        ERASE
        @ Axes
        (0., 0.)
        maxcoordx 10 / IP
        "y, km" "x, km"
        4 \->LIST AXES
        DRAX
        LABEL
        {#0d, #0d} PVIEW
        (0., 0.) rpkm 0 360 ARC
        orbit LIST\->
        DUP
        IF 0 ==
        THEN
          DROP
        ELSE
          1 SWAP FOR i
            C\->R
            SWAP 1000 / SWAP
            DUP2
            COS * IP
            3 ROLLD
            SIN * IP
            R\->C
            IF i 1 >
            THEN
              DUP prevpoint LINE
            END
            'prevpoint' STO
          NEXT
          'prevpoint' PURGE
        END
        0 WAIT DROP
      »
    » 'showorbit2' STO

    @ Store points of orbit in polar coords
    «
      \-> pr pphi dinc
      «
        pphi IP deginc MOD
        IF 0 ==
        THEN
          orbit SIZE dinc * DUP
          IF 0 == SWAP pphi ABS IP < OR
          THEN
            orbit LIST\->
            pr pphi R\->C
            SWAP 1 +
            \->LIST
            'orbit' STO
            r rmax MAX 'rmax' STO
          END
        END
      »
    » 'orbitaddpoint' STO

    showhelp
    
    DO
      IF newgame 1 ==
      THEN
        paramsinit
        paramsinput
        0 'newgame' STO
        1 'toinit' STO
      END
      
      IF toinit
      THEN
        xmin xmax XRNG
        ymin ymax YRNG
        ERASE
        @ Axes
        xmax ymax R\->C
        xmax xmin - 10 / IP ymax ymin - 8 / IP
        2 \->LIST
        "" ""
        4 \->LIST AXES
        DRAX
        {#0d, #0d} PVIEW
        @ Axes labels
        @ X
        IF xmin 0 < xmax 0 > AND
        THEN
          (0, 0) C\->PX LIST\-> DROP2
          #3d 2 \->LIST
          0.
            showrepl @ Show 0 on "x" axe
        END
        {#0d, #3d} xmin
          showrepl
        dispwidth xmax LOG IP 1 + 5 * - R\->B
        #3d
        2 \->LIST
        xmax
          showrepl
        @ Y
        dispwidth 10 - R\->B
        dispheight 8 - R\->B 2 \->LIST
        0.
        showrepl @ Show 0 on "y" axe
        dispwidth ymax LOG IP 1 + 5 * - R\->B
        #10d
        2 \->LIST
        ymax
        showrepl

        {#0d, #9d} "H:"
        showrepl
        {#0d, #15d} IF showdist THEN "L:" ELSE "X:" END
        showrepl
        {#0d, #21d} "\Gg:"
        showrepl
        {#0d, #41d} "a:"
        showrepl
        {#0d, #47d} "\Ga:"
        showrepl
@        {#100d, #47d} "\GD\Ga:\177"
@        showrepl
        {#0d, #54d} "V:"
        showrepl
        {#0d, #60d} "U:"
        showrepl
        {#0d, #67d} "LS:"
        showrepl
        {#0d, #73d} "F:"
        showrepl
      END

      phin1 phi toinit
      showorbit1
      hn1 IP h IP {#12d, #9d} toinit
      showgxor
      IF showdist THEN ln1 l ELSE xn1 x END
      IP SWAP IP SWAP {#12d, #15d} toinit
      showgxor
      phin1 1 RND phi 1 RND {#12d, #21d} toinit
      showgxor
      an1 a {#12d, #41d} toinit
      showgxor
      acn1 ac {#12d, #47d} toinit
      showgxor
@      dacn1 dac {#117d, #47d} toinit
@      showgxor
      vn1 1 RND v 1 RND {#12d, #54d} toinit
      showgxor
      un1 1 RND u 1 RND {#12d, #60d} toinit
      showgxor
      lsn1 ls {#12d, #67d} toinit
      showgxor
      mfn1 IP mf IP {#12d, #73d} toinit
      showgxor

      @ Calculate points as a function of coordonates
      IF
        toinit
        ac acn1 \=/ OR
        h hn1 \=/ OR
        showdist NOT x xn1 \=/ AND OR
        showdist l ln1 \=/ AND OR
      THEN
        IF toinit NOT
        THEN
          IF showdist THEN ln1 ELSE xn1 END
          hn1
          DUP2
          acn1
          showship
        END
        IF showdist
        THEN
          ln1 hn1 l h
        ELSE
          xn1 hn1 x h
        END
        ac
        showship
      END

      stepdelay WAIT
      0 'toinit' STO
      
      @ Prevoius iteration values
      a 'an1' STO
      ac 'acn1' STO
      v 'vn1' STO
      u 'un1' STO
      dac 'dacn1' STO
      h 'hn1' STO
      x 'xn1' STO
      l 'ln1' STO
      ls 'lsn1' STO
      mf 'mfn1' STO
      phi 'phin1' STO

      WHILE KEY
      REPEAT
        \-> k
        «
          CASE
            k 25 ==
            k 35 == OR THEN
              a da IF k 25 == THEN + ELSE - END
              DUP IF 0 < THEN DROP 0 END
              DUP IF alim > THEN DROP alim IP END
              'a' STO
            END
            k 31 == THEN
              showorbit2
              1 'toinit' STO
            END
            k 34 ==
            k 36 == OR THEN
              ac dac IF k 34 == THEN - ELSE + END
              @ Cyclic transform like 190°->-170; -190->170
              DUP ABS
              IF 180 >
              THEN
                DUP SIGN 360 * -
              END
              'ac' STO
            END
            @ Switch increments
            k 92 == THEN 1 'dt' STO END
            k 93 == THEN 10 'dt' STO END
            k 94 == THEN 100 'dt' STO END
            k 11 == THEN
              IF dac 1 == THEN 10 ELSE 1 END 'dac' STO
            END
            k 12 == THEN
              IF da 1 == THEN 0.5 ELSE 1 END 'da' STO
            END
            k 16 == THEN 0 'a' STO END
            @ Game restart/end
            k 42 == THEN 1 'newgame' STO END
            k 51 == THEN 1 'tostop' STO END
          END
        »
      END
      
      ls dt - 'ls' STO
      dt 't' STO
      calcmaneuver
      r phi deginc
      orbitaddpoint
      
      IF h hn1 < h 0 == AND
      THEN
        CASE
          v ABS 2 <
          u ABS 2 < AND THEN "Perfect landing!" END
          v ABS 4 <
          u ABS 4 < AND THEN "Good landing!" END
          v ABS 6 <
          u ABS 6 < AND THEN "Hard landing!" END
          v ABS 8 <
          u ABS 8 < AND THEN "Very hard landing! Ambulance ship was sent!" END
          "Landing failed. Ship is destroyed!"
        END
        MSGBOX
        {#0d, #0d} PVIEW
      END

      @ Scaling coordinates
      @ Zoom out
      xmax xmin -
      ymax ymin -
      IF showdist THEN l ELSE x END
      v dt * 50 *
      \-> dx dy currx xincr
      «
        IF
          ymax h - ABS dy 0.2 * <
        THEN
          ymax 2 * IP 'ymax' STO
          1 'toinit' STO
        ELSE
          IF
            ymin h - ABS dy 0.2 * <
          THEN
            h 1.5 * IP
            DUP
            IF ymax0 <
            THEN
              DROP
              ymax0
            END
            DUP
            IF ymax \=/
            THEN
              'ymax' STO
              1 'toinit' STO
            ELSE
              DROP
            END
          END
        END
        IF
          xmax currx - ABS dx 0.2 * <
        THEN
          currx xincr + IP 'xmax' STO
          currx xincr 2.5 / - IP 'xmin' STO
          1 'toinit' STO
        ELSE
          IF xmin currx - ABS dx 0.2 * <
          THEN
            currx xincr + IP 'xmin' STO
            currx xincr 2.5 / - IP 'xmax' STO
            1 'toinit' STO
          END
        END
      »

    UNTIL
      tostop
    END
  »
  
  cleanup
»


HOME
'Lunar' PURGE
'Lunar' STO
CLEAR
CLLCD
@ show the VAR menu
2. MENU
11.1 KEYEVAL

