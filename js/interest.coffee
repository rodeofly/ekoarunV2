  
monomeString_to_array = (s, regex = /([\+\-]?\d+(?:\/\d+)*)((?:.(?:\w+)\^(?:\d+))*)/g) ->
  switch (match = regex.exec s).length
    when 0 then alert "Vous devriez effacer l'invite de commande et envisager quelquechose de mieux pondéré...ok !?"
    else return match[1..]

obtenir_la_solution = (id) ->
  if $( "#equation_#{id} > ul.membre.gauche > li").length is 1 and $( "#equation_#{id} > ul.membre.droite > li").length is 1
    $li_gauche = $( "#equation_#{id} > ul.membre.gauche > li")
    $li_droite = $( "#equation_#{id} > ul.membre.droite > li")
    if $li_gauche.attr("data-symbol") and not $li_droite.attr("data-symbol")
      if $li_gauche.attr("data-fraction") is "1/1" or $li_gauche.attr("data-fraction") is "1"
        [signe, s] = [$( "#signe_#{id}" ).text(), fracString_to_frac($li_droite.attr( "data-fraction")).irreductible().toHtml()]
        switch signe
          when "=" then solution = "S = {#{s}}"
          when ">" then solution = "S = ]#{s} ; +∞ ["
          when "≥" then solution = "S = [#{s} ; +∞ ["
          when "<" then solution = "S = ] -∞ ; #{s}]"
          when "≤" then solution = "S = ] -∞ ; #{s}]"                
        $("#solution_#{id}").html solution
      else alert "On ne peut pas encore lire la solution ! il faut que le coefficient _ l'inconnue soit 1."
    else alert "On ne peut pas encore lire la solution ! il faut une l'inconnue à gauche et une valeur à droite." 
  else alert "On ne peut pas encore lire la solution ! il faut un seul terme à gauche et un seul terme à droite." 
    
    
    
   <button class="obtenirSolution"  title="Obtenir la solution de cette équation">?</button>
                              <button class="copier"  title="Copier cette valeur">&#169;</button>
                              <button class="coller"  title="Injecter la valeur">&#8618;</button>
   # selectionner un terme
  $('body').on "click", "ul", (event) ->
    event.stopPropagation()
    op = get_operateur( $( this ) )
    $( "#equation_string").val op.toStringId()
    
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
    
    
  $( "body" ).on "click", ".obtenirSolution",       () -> obtenir_la_solution(id) if id = get_focused_id()
  
###################################################################################################
###################################################################################################
###################################################################################################
# Graph
  <button id="plotter">Draw</button> <button id="eraser">clear</button> 
  
  
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

