$( op.id ).sortable connectWith: ".#{op.type}", helper : "clone", revert : true, receive : (event, ui) ->
      event.stopImmediatePropagation()
      console.log "waat"
      if not ( ( "#{op.id}" is ui.sender.parent().attr("id") ) or ( "#{op.parent_id}" is ui.sender.attr("id") ) ) 
        ui.sender.sortable("cancel")
      else
        if (ui.sender.children("ul, li").length is 0)
          switch op.type
            when "addition"       then (new Monome()).insert( ui.sender.attr('id'), new Fraction(0,1) )
            when "multiplication" then (new Monome()).insert( ui.sender.attr('id'), new Fraction(1,1) )
           
           
           
           
           
           
           
           
           
           $( "#{op.id} > li.monome" ).droppable accept : "#{op.id} > li.monome", hoverClass : "ui-state-hover", activeClass: "ui-state-highlight", drop: (event, ui) -> 
      m1 = new Monome ui.draggable   
      m2 = new Monome $(this)
      switch op.type
        when "addition"
          if ((m1.symbol is m2.symbol) and (m1.power is m2.power))
            m2.fraction.ajouter m1.fraction  
            m2.update()
            m1.remove()
          else
            if (m1.power isnt m2.power)
              alert "attention, ce n'est pas la meme puissance !"
            else
              alert "On ne peut pas tout mélanger !"
        when "multiplication"
          if (m1.symbol is m2.symbol)
            m2.fraction.multiplier m1.fraction
            m2.power += 1
            m2.update()
            m1.remove()
          else if m2.symbol is "1"
            m1.fraction.multiplier m2.fraction
            m1.update()
            m2.remove()
          else if m1.symbol is "1"
            m2.fraction.multiplier m1.fraction
            m2.update()
            m1.remove()
          else
            m2.fraction.multiplier m1.fraction
            m1.fraction = new Fraction 1,1
            m2.update()
            m1.update()         
      megateuf()
            
    $( "#{op.id} > ul.operateur" ).droppable accept : "#{op.id} > li.monome", hoverClass : "ui-state-hover", activeClass: "ui-state-highlight", drop: (event, ui) ->
      m = new Monome ui.draggable 
      op2 = new Operateur("##{$(this).attr('id')}")
      if op2.type is op.type
        $( op2.id ).append $( m.id )
      else if op.type is "addition" and op2.type is "multiplication"
        op3= new Operateur( op2.id , op.symbol ).monomesString_insert( [m.toString()] )
        $( m.id ).remove()
      else if op.type is "multiplication" and op2.type is "addition"
        $( op2.id ).children( "ul, li" ).each ->
          op3= new Operateur( "##{$(this).attr('id')}" , op.symbol ).monomesString_insert( [m.toString()] )
        $( m.id ).remove()
      megateuf()  
      
      
      
monomeString_to_array = (s, regex = /([\+\-]?\d+(?:\/\d+)*)((?:.(?:\w+)\^(?:\d+))*)/g) ->
  switch (match = regex.exec s).length
    when 0 then alert "Vous devriez effacer l'invite de commande et envisager quelquechose de mieux pondéré...ok !?"
    else return match[1..]
    
    
    
    
      #Obtenir la solution de l'equation s'il ne reste plus qu'un symbole à gauche
  $( "body" ).on "click", ".obtenirSolution", () -> obtenir_la_solution(id) if id = get_focused_id()
  # operation par le contenu de la console chaque membre de l'equation
  $( "body" ).on "click", ".multiplier_distribuer", () -> operation_sur_equation( "multiplier_distribuer" )   
  $( "body" ).on "click", ".multiplier_factoriser", () -> operation_sur_equation( "multiplier_factoriser" )   
  $( "body" ).on "click", ".diviser",    () -> operation_sur_equation( "diviser" )
  $( "body" ).on "click", ".ajouter",    () -> operation_sur_equation( "ajouter" )
  $( "body" ).on "click", ".retrancher", () -> operation_sur_equation( "retrancher" )
  $('body').on "click", ".equation", () ->
    $( ".focus" ).toggleClass("focus")
    $( "#equation_panel").show().appendTo $( this ).toggleClass("focus")
  $( "body" ).on "click", ".copier", () ->
    id = get_focused_id()    
    activer_copier_symbole = $( "#equation_#{id} > ul.membre.gauche > li").attr("data-symbol")
    activer_copier_contenu = $( "#equation_#{id} > ul.membre.droite > li")
    alert "symbole copié : #{activer_copier_symbole}"
    
    
  # effectuer la somme, par membre, des termes selectionnés
  $( "body" ).on "click", ".sommationMonome", () -> 
    if id = get_focused_id()
      $( ".operateur.addition" ).each ->
        selected = $( this ).find( ".selected" )
        coeffs = {}
        coeffs["rationnel"] = new Fraction 0, 1
        op_id = "##{$( this ).attr('id')}"
        $( selected ).each ->
          m = new Monome($( this ))        
          coeffs[  m.symbol   ] = if coeffs[m.symbol]? then m.fraction.ajouter coeffs[m.symbol] else m.fraction
        for symbol, fraction of coeffs
          m = new Monome()
          m.insert( op_id, fraction, symbol)
        $( selected ).remove()

   $( "body" ).on "click", ".coller", () ->
    check_substitute = (id) ->     
      #alert activer_copier_symbole + " vs " + $( this ).attr( "data-symbol")
      if $( this ).attr( "data-symbol") is activer_copier_symbole
        fraction1 = fracString_to_frac $( this ).attr( "data-fraction") 
        activer_copier_contenu.each ->
          fraction2 = fracString_to_frac $( this ).attr("data-fraction")
          value = fraction1.multiplier fraction2
          (new Monome()).insert id, side, value, symbol
          $( this ).hide "easeInElastic", () -> $( this ).remove()           
    id = get_focused_id()    
    $( "#equation_#{id}" ).find( "li").each -> check_substitute(id)  
    
    
    
    ###################################################################################################
###################################################################################################
###################################################################################################
# Graph
  board = JXG.JSXGraph.initBoard('box', {boundingbox:[-5,8,8,-5], axis:true})
  # Macro function plotter
  addCurve = (board, func, atts) -> f = board.create('functiongraph', [func], atts)
  # Simplified plotting of function
  plot = (func, atts) ->
    if (atts==null)
      return addCurve(board, func, {strokewidth:2})
    else
      return addCurve(board, func, atts)
  #Free point
  p = board.create('point', [1,1], {style:6, name:'p'})
  
  clearAll = () ->
    JXG.JSXGraph.freeBoard(board)
    board = JXG.JSXGraph.initBoard('box', {boundingbox:[-5,8,8,-5], axis:true})
    p = board.create('point', [3,-4], {style:6, name:'p'})
    
  doIt = () ->
    s = $( "#equation_string" ).val()
    s = s.replace(/[\(]/g,"").replace(/\)/g,"").replace(/\x/g,"*x").replace(/\+\-/, "-")
    f = s.split(/[=<>≤≥]/)[0]
    f = "function f(x){ return #{f};};plot(f);"
    g = s.split(/[=<>≤≥]/)[1]
    g = "function g(x){ return #{g};};plot(g);"
    eval(f+g)
  
  $( "#plotter" ).on "click", () -> doIt()
  $( "#eraser" ).on "click", () -> clearAll()
  $( "#toggle-box" ).on "click", -> $( "#box, #close-box" ).toggle()
  $( "#plotter" ).on "click", -> $( "#box, #close-box" ).show()

