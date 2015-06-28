
unique_id = 1
debug = false
activer_copier_symbole= ""
activer_copier_contenu= {}
liste_des_chiffres =   ['1','2','3','4','5','6','7','8','9','0'] 
liste_des_operateurs = ['+','-'] 
signes =  ['≤', '≤', '≥', '>', '<', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=', '=']
liste_des_variables =  ['x','y','z','t']
liste_des_signes =     ['=','<','>','≤','≥']
changementSens = { '=': '=', '<': '>', '>': '<', '≤': '≥', '≥': '≤' }

###################################################################################################
###################################################################################################
###################################################################################################
# Fraction
fracString_to_frac = (value) ->
  #console.log "fracString_to_frac(#{value}) starts !" 
  foo = value.split("/")
  switch foo.length
    when 2
      [n,d] = [parseInt(foo[0]), parseInt(foo[1])]
      if n? and d? then foo = new Fraction n,d else alert "Erreur : fracString_to_frac, n is #{n} and d is #{d} !"
    when 1
      n = parseInt(foo[0])
      if n? then foo = new Fraction n,1 else alert "Erreur : fracString_to_frac, n is #{n} !"
    else
      alert "Erreur : fracString_to_frac, value is #{value} !"

class Fraction
  constructor: (@numerateur, @denominateur) ->
  
  irreductible: () ->
    [a, b] = [@numerateur, @denominateur]
    [a, b] = [b, a%b] until b is 0
    [@numerateur, @denominateur ] = [@numerateur / a, @denominateur / a ]
    if @denominateur < 0 then [@numerateur , @denominateur] = [-@numerateur, -@denominateur]
    return this

  inverse: () ->
    if @numerateur isnt 0
      [@numerateur,@denominateur]=[@denominateur,@numerateur]
      return this
  
  oppose: () ->
    @numerateur = -@numerateur
    return this
  
  toString: () -> return "#{@numerateur}/#{@denominateur}"
  
  toHtml: () ->
    if @denominateur is 1
      if @numerateur < 0
        html = "<span class='moins'>&minus;</span><span class='rationnel'>#{Math.abs(@numerateur)}</span>"
      else
        html = "<span class='plus'>&plus;</span><span class='rationnel'>#{@numerateur}</span>"
    else
      if @numerateur < 0
        html = "<span class='moins'>&minus;</span><span class='fraction'><span class='top'>#{Math.abs(@numerateur)}</span><span class='bottom'>#{@denominateur}</span></span>"
      else
        html = "<span class='plus'>&plus;</span><span class='fraction'><span class='top'>#{@numerateur}</span><span class='bottom'>#{@denominateur}</span></span>"
 
  ajouter: (fraction) ->
    if @nominateur isnt fraction.denominateur
      [@numerateur, @denominateur] = [@numerateur * fraction.denominateur + fraction.numerateur * @denominateur,  @denominateur * fraction.denominateur]
    else
      [@numerateur, @denominateur] = [@numerateur + fraction.numerateur, @denominateur]
    return this
    
  multiplier: (fraction) -> 
    [@numerateur, @denominateur] = [@numerateur * fraction.numerateur, @denominateur * fraction.denominateur]
    return this

###################################################################################################
###################################################################################################
################################################################################################### 
# Monomes
monomeString_to_array = (s) ->
  console.log "monomeString_to_array(#{s})" if debug
  pattern_terme = /\([\+\-]*\d+[/\d+]*\)(\w+²{0,1})*/g
  foo = s.match(pattern_terme)
  if (foo? and foo[0] is s)
    alert "#{s} match regex:#{pattern_terme}" if debug
    foo = s.split(")")
    foo = if foo[1] then [foo[0][1..], foo[1]] else [foo[0][1..]]
  else
    alert "Vous devriez effacer l'invite de commande et envisager quelquechose de mieux pondéré...ok !?"
    
class Monome
  constructor: ($monome) ->
    if $monome
      @id = "##{$monome.attr('id')}"
      @parent_id = "##{$( @id ).parent().attr('id')}"
      @side = if $( @id ).hasClass( "gauche" ) then "gauche" else "droite"
      @fraction = fracString_to_frac $( @id ).attr("data-value")
      @type = $( @id ).attr("data-type")
      @symbol = if @type is "symbol" then $( @id ).attr("data-symbol") else ""
    else
      @id = "##{unique_id++}"
  
  update : () ->
    $( @id ).attr "data-value", @fraction.toString() 
    $( @id ).html( this.html_content() )
       
          
  irreductible : () -> 
    @fraction.irreductible()
    this.update()
  
  remove : () -> $( @id ).remove()
  
  html_content : () ->
    switch @type
      when "symbol"
        if @fraction.numerateur*@fraction.denominateur in [-1,1]
          if @fraction.numerateur/@fraction.denominateur is 1
            html = "<span class='droppable'><span class='plus' >+      </span><span>#{@symbol}</span></span>"
          else html = "<span class='droppable'><span class='moins'>&minus;</span><span>#{@symbol}</span></span>"
        else html = "<span class='droppable'>#{@fraction.toHtml()}<span>#{@symbol}</span></span>"                   
      else html = "<span class='droppable'>#{@fraction.toHtml()}</span>"   
    
  toHtml: () ->
    html = "<li id='#{@id[1..]}' class='monome item' data-value='#{@fraction.toString()}' data-type='#{@type}' data-symbol='#{@symbol}'><span class='monome_html'>#{this.html_content()}</span></li>"
  
  insert: (id, @fraction, @symbol) ->
    @type = if @symbol? then "symbol" else "rationnel"
    html = "<li id='#{@id[1..]}' class='monome item' data-value='#{@fraction}' data-type='#{@type}' "
    html += if @symbol? then "data-symbol='#{@symbol}'></li>" else "></li>"
    $( id ).append html
    this.update()
    
  insert_from_string : ( @equation_id, monomeString) ->
    m = monomeString.split(")")
    fraction = fracString_to_frac m[0][1..]
    if m[1] then (new Monome()).insert( @equation_id, fraction, m[1]) else (new Monome()).insert( @equation_id, fraction)
      
  ajouter: (monome) ->
    if ( (@type is monome.type) and ( (@type is "rationnel") or (@symbol is monome.symbol) ) )
      @fraction.ajouter monome.fraction
    else
      alert "On ne mélange pas symboles & chiffres !"
    return this
  
  toString: () ->
    switch @type
      when "rationnel" then s = "(#{@fraction.toString()})"
      else                  s = "(#{@fraction.toString()})#{@symbol}"
  
  toArray: () -> monomeString_to_array(this.toString())

###################################################################################################
###################################################################################################
###################################################################################################
#Operateur
class Operateur
  constructor: (id, @symbol, membre) ->
    classe = {"*": "multiplication", "+" : "addition"}    
    if @symbol?
      @type = classe[@symbol]
      @id = unique_id++
      html = "<ul id='#{@id}' class='operateur #{@type} item' data-symbol='#{@symbol}'></ul>"   
      @id = "##{@id}"
      switch $( id ).attr "data-symbol"
        when @symbol then $( id ).append html
        else $( id ).wrap html
    else
      @id = id
      @symbol = $( @id ).attr("data-symbol")
      @type = classe[@symbol]
    @parent_id = "##{$( @id ).parent().attr('id')}"
    this.update()
          
  update: () -> return this  
  
  monomesString_insert: (membre) -> (new Monome()).insert_from_string(@id, monomeString) for monomeString in membre
  
###################################################################################################
###################################################################################################
###################################################################################################
#Équation
              
generate_equation_string = (n, min = -10, max = 10) ->
  equation = {}
  equation["signe"] = signes[Math.floor Math.random() * signes.length]
  for side in ["gauche", "droite"]
    str= ""
    for [1..n]
      coeff = Math.floor(Math.random() * (max-min+1)) + min
      toss = Math.floor(Math.random() * (2)) - 1
      str += if toss is 0 then "+(#{coeff}) " else "+(#{coeff})x "
    equation[side] = str[1..] 
  equation = "#{equation['gauche']} #{equation['signe']} #{equation['droite']}"
  
generate_equation = (unknown, factor_length, depth, min = -10, max = 10) ->
  id = unique_id++
  signe = signes[Math.floor Math.random() * signes.length]
  html =
  """
  <div id='equation_#{id}' class='equation' >
      <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>x</button>    
      <p id='solution_#{id}'></p>
      <ul id='fake'></ul>
      <span id='signe_#{id}' class='signe'>#{signe}</span>
  </div>
  """
  $( "#equations_div" ).append html

  $( "#fake" ).remove()  
  $("#equations_div" ).sortable()
  

  
  Array::shuffle ?= ->
  if @length > 1 then for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
    return this
    
  alphabet = ['a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

  op = new Operateur("#fake", "+")
  membre = []
  for i in [1..unknown]
    monomeString = ""
    for [1..factor_length]
      [ coeff, toss ] = [ Math.floor(Math.random() * (max-min+1)) + min, Math.floor(Math.random() * (2)) - 1 ]      
      monomeString += if toss is 0 then "(#{coeff})" else "(#{coeff})#{alphabet[i]}"
    membre.push monomeString
  alert membre
  op.monomesString_insert( membre ) 
  
  

obtenir_la_solution = (id) ->
  if $( "#equation_#{id} > ul.membre.gauche > li").length is 1 and $( "#equation_#{id} > ul.membre.droite > li").length is 1
    $li_gauche = $( "#equation_#{id} > ul.membre.gauche > li")
    $li_droite = $( "#equation_#{id} > ul.membre.droite > li")
    if $li_gauche.attr("data-symbol") and not $li_droite.attr("data-symbol")
      if $li_gauche.attr("data-value") is "1/1" or $li_gauche.attr("data-value") is "1"
        [signe, s] = [$( "#signe_#{id}" ).text(), fracString_to_frac($li_droite.attr( "data-value")).irreductible().toHtml()]
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

ajouter_membre = (string) ->
  id = get_focused_id()
  if (id )
    $( "#equation_#{id} > .operateur" ).each ->  
      (operateur = new Operateur( "##{$(this).attr('id')}" , "+")).monomesString_insert( string )

multiplier_distribuer_membre = (facteur) ->
  id = get_focused_id()
  if (id and facteur.denominateur)
    $( "#equation_#{id} > ul > li.monome").each ->
      m = new Monome $( this )
      m.fraction.multiplier facteur
      m.update()

multiplier_factoriser_membre = (string) ->
  id = get_focused_id()
  if (id )
    $( "#equation_#{id} > .operateur" ).each ->  
      (operateur = new Operateur( "##{$(this).attr('id')}", "*")).monomesString_insert( string )

get_focused_id = () -> id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
  
operation_sur_equation = (mode, id) ->
  $( "#equation_string" ).val( "#{$( '#equation_string' ).val()})" ) if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres
  id = get_focused_id()
  array = monomeString_to_array $( "#equation_string" ).val()
  if (id? and array?)
    switch mode
      when "diviser"               then multiplier_distribuer_membre fracString_to_frac array[0], array[1]
      when "multiplier_factoriser" then multiplier_factoriser_membre $( "#equation_string" ).val().split("+")
      when "multiplier_distribuer" then multiplier_distribuer_membre fracString_to_frac array[0], array[1]
      when "retrancher"            then ajouter_membre (fracString_to_frac array[0] ).oppose(), array[1]
      when "ajouter"               then ajouter_membre $( "#equation_string" ).val().split("+")
  else alert "Poids surement mal formé !" 

# On Dom Ready !
$ ->
  $( "#generer_equation_complexe" ).on "click", ( ) -> generate_equation(2, 2, 2, -10, 10)
  # selectionner un terme
  $('body').on "click", "ul", (event) ->
    if ( ($(this).children().length is 1) and ( $(this).children("ul").length is 1) )
      $(this).contents().unwrap()
    if ( ($(this).children().length is 1) and ( not $(this).parent().hasClass("equation") ) )
      $(this).contents().unwrap()
###################################################################################################
###################################################################################################
###################################################################################################
# Init
  do once = () ->
    $( "#toggle_help" ).on "click", -> $( "#help, #aside, #footer" ).toggle()
    $( "#help, #aside, #footer" ).toggle()
###################################################################################################
###################################################################################################
###################################################################################################  
  $( ".operateur" ).on "click", ->
    if (($(this).children().length < 2) or ($(this).attr('data-symbol') is $(this).parent().attr('data-symbol')) )
      $(this).unwrap() 
  $( "#generer_equation" ).on "click", -> $( "#equation_string" ).val generate_equation_string Math.floor(10*Math.random())+1
  
  $( "#inserer_equation" ).on "click", ( ) ->
    s = $( "#equation_string" ).val()
    if (s.slice(-1) in liste_des_chiffres) then $( "#equation_string" ).val( "#{s})" ) 
    s = $( "#equation_string" ).val().replace(/\s+/g, '') # On récupère l'equation sans whitespaces \s+
    pattern_equation = /((?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*)(?:\+(?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*))*)([<≤=≥>])((?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*)(?:\+(?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*))*)/g
    switch (match = pattern_equation.exec(s)).length
      when 0 then alert "Vérifier que l'équation est correctement formatée"
      else
        [signe, mdg, mdd, id ] = [ match[2], match[1].split("+"), match[3].split("+"), unique_id++ ]
        html =
        """
        <div id='equation_#{id}' class='equation' >
            <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>x</button>    
            <p id='solution_#{id}'></p>
            <ul id='fakeg'></ul>
            <span id='signe_#{id}' class='signe'>#{signe}</span>
            <ul id='faked'></ul>
        </div>
        """
        $( "#equations_div" ).append html
        (operateur = new Operateur("#fakeg", "+")).monomesString_insert( mdg )  
        (operateur = new Operateur("#faked", "+")).monomesString_insert( mdd ) 
        $( "#fakeg, #faked" ).remove()  
        $("#equations_div" ).sortable()
        $( "#equation_#{id}" ).trigger "click"      

  # effacer l'invite _ commande
  $("#effacer_equation_string").on "click", ->  $( "#equation_string" ).val( "" )
  
  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", (event) ->
    $("#equation_#{id}.focus ul > .monome").addClass( "selected" ) if id = get_focused_id()
  
  #Simplifier les fractions selectionnées d'une équation
  monome_irreductible = ($monome) -> (m = new Monome($monome)).irreductible()
  $( "body" ).on "dblclick", ".monome", () -> monome_irreductible $(this)
  $( "body" ).on "click", ".simplifier_les_monomes", () -> if id = get_focused_id() then $( "#equation_#{id} > ul > li.selected" ).each -> monome_irreductible $(this)
  
  # selectionner un terme
  $('body').on "mousedown", "li", (event) ->
    m = new Monome $( this )
    op = new Operateur m.parent_id

    # Addition
    switch op.type
      when "addition"
        if m.fraction.numerateur is 0
          switch $( "#{m.id}" ).siblings().length
            when 0
              [m.type, m.fraction.numerateur ] = ["rationnel", 0 ]
              m.update()
            else $( "#{m.id}" ).remove()                    
      when "multiplication"
        if ( ( m.type is "rationnel" ) and ( m.fraction.numerateur/m.fraction.denominateur is 1 ) ) # Si c'est un un il y a traitement particulier
          switch $( "#{m.id}" ).siblings().length
            when 0
              [m.type, m.fraction.numerateur ] = ["rationnel", 1 ]
              m.update()
            else $( "#{m.id}" ).remove()       
    $( op.id ).sortable connectWith: ".#{op.type}", revert : true, receive : (event, ui) ->
      if not ( ( "#{op.id}" is ui.sender.parent().attr("id") ) or ( "#{op.parent_id}" is ui.sender.attr("id") ) ) 
        ui.sender.sortable("cancel")
      else
        if (ui.sender.children("ul, li").length is 0)
          switch op.type
            when "addition"       then (new Monome()).insert( ui.sender.attr('id'), new Fraction(0,1) )
            when "multiplication" then (new Monome()).insert( ui.sender.attr('id'), new Fraction(1,1) )
         
    $( m.id ).siblings("li").droppable  accept : "#{m.id}", hoverClass : "ui-state-hover", activeClass: "ui-state-highlight", drop: (event, ui) -> 
      m1 = new Monome $( m.id )   
      m2 = new Monome $(this)
      if $( m.parent_id ).hasClass( "addition" )
        if (m1.type is m2.type)
          if  (m1.type is "rationnel") or (m1.symbol is m2.symbol)
            m2.fraction.ajouter m1.fraction  
            m2.update()
            m1.remove()
          else
            alert "On ne mélange pas symboles & chiffres !"
      else if $( m.parent_id ).hasClass( "multiplication" )  
        if $( m2.id ).hasClass( "monome" )
          m2.fraction.multiplier m1.fraction  
          m2.update()
          m1.fraction = new Fraction 1, 1
          m1.update() 
        else         
          op2 = new Operateur( m.id, op.symbol ).monomesString_insert( m2.toString )
   
    $( m.id ).siblings("ul").droppable  accept : "#{m.id}", hoverClass : "ui-state-hover", activeClass: "ui-state-highlight", drop: (event, ui) ->
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
    $( "#equation_string").val m.toString() # Sinon on l'affiche dans la console
                      
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
          switch m.type
            when "symbol"
              coeffs[  m.symbol   ] = if coeffs[m.symbol]? then m.fraction.ajouter coeffs[m.symbol] else m.fraction
            when "rationnel" then coeffs[ "rationnel" ] = m.fraction.ajouter coeffs[ "rationnel" ]     
        for symbol, fraction of coeffs
          m = new Monome()
          switch symbol
            when "rationnel" then m.insert( op_id, fraction)
            else m.insert( op_id, fraction, symbol)
        $( selected ).remove()

   $( "body" ).on "click", ".coller", () ->
    check_substitute = (id) ->     
      #alert activer_copier_symbole + " vs " + $( this ).attr( "data-symbol")
      if $( this ).attr( "data-symbol") is activer_copier_symbole
        fraction1 = fracString_to_frac $( this ).attr( "data-value") 
        activer_copier_contenu.each ->
          fraction2 = fracString_to_frac $( this ).attr("data-value")
          value = fraction1.multiplier fraction2
          type = $( this ).attr("data-type")       
          if type is "rationnel"
            (new Monome()).insert id, side, value
          else
            (new Monome()).insert id, side, value, "#{symbol}"
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

###################################################################################################
###################################################################################################
###################################################################################################
# Le petit panel tactile    
  for char in  liste_des_variables.concat liste_des_operateurs.concat ["/"].concat liste_des_signes
    $("#equation_panel").append("<button id='var_#{char}' class='panel_touch'>#{char}</button>")
  #$("#equation_panel").append("<br>")
  for char in liste_des_chiffres
    $("#equation_panel").append("<button id='var_#{char}' class='panel_touch'>#{char}</button>")
  $( "button" ).button()
  
  #Saisie 'intelligente' _ l'equation   
  $('body').on "click", ".panel_touch", () ->
    [char, saisie ] = [$( this ).attr( "id" ).split("_")[1], $( "#equation_string" ).val() ]
    caractere_precedent = if (saisie.length > 0) then saisie.slice(-1) else ''       
    if char is '←'
      saisie = if saisie.length < 2 then "" else saisie[0..(saisie.length-2)]
    else
      if caractere_precedent is ''
        if char in liste_des_operateurs     then saisie += (if (char is '-') then "(-" else "(" )
        else if char in liste_des_chiffres  then saisie += "(#{char}"
        else if char in liste_des_variables then saisie += "(1)#{char}"
        else if char in liste_des_signes    then alert "il faut un membre à gauche !"
        else if char is '/'                 then alert "Impossible de commencer par ça !"
      
      else if caractere_precedent in liste_des_operateurs or caractere_precedent is '('
        if char in liste_des_operateurs
          if caractere_precedent isnt '-'   then saisie += (if char is '-' then "#{char}" else alert "Deux opérateurs d'affilés ?")
          else alert "Deux fois le même opérateur ?"
        else if char in liste_des_chiffres  then saisie += "#{char}"
        else if char in liste_des_variables then saisie += "1)#{char}"
        else if char in liste_des_signes    then alert "Effacer le dernier signe !"
        else if char is '/'                 then alert "Impossible d'ecrire #{caractere_precedent}#{char} !"
      
      else if caractere_precedent in liste_des_chiffres
        if char in liste_des_operateurs     then saisie += (if char is '-' then ")+(-" else ")#{char}(")
        else if char in liste_des_chiffres  then saisie += "#{char}"
        else if char in liste_des_variables then saisie += ")#{char}"
        else if char in liste_des_signes    then saisie += ")#{char}"
        else if char is '/' then saisie += "#{char}"
      
      else if caractere_precedent in liste_des_variables
        if char in liste_des_operateurs     then saisie += (if char is '-' then "+(-" else "#{char}(")
        else if char in liste_des_chiffres  then alert "Les coefficients se placent devant les variables !"
        else if char in liste_des_variables then saisie += "#{char}"
        else if char in liste_des_signes    then saisie += "#{char}"
        else if char is '/'                 then alert "Impossible d'ecrire #{caractere_precedent}#{char} !"
      
      else if caractere_precedent in liste_des_signes
        if char in liste_des_operateurs     then saisie += (if char is '-' then "(-" else "(")
        else if char in liste_des_chiffres  then saisie += "(#{char}"
        else if char in liste_des_variables then saisie += "(1)#{char}"
        else if char in liste_des_signes    then alert "_ux signes d'affilés"
        else if char is '/'                 then alert "Impossible d'ecrire #{caractere_precedent}#{char} !"  
      
      else if caractere_precedent is '/'
        if char in liste_des_operateurs     then alert "Impossible d'ecrire #{caractere_precedent}#{char} !"
        else if char in liste_des_chiffres  then saisie += "#{char}"
        else if char in liste_des_variables then alert "Et la fraction ?" 
        else if char in liste_des_signes    then alert "Et la fraction ?"
        else if char is '/'                 then alert "Ca y est déjà !"
      else
        saisie += "#{char}"
    $( "#equation_string" ).val(saisie)

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

  $( "body" ).on "click", ".deleteButton", (event) ->
    event.stopPropagation() # important pour ne pas perdre #equation_panel
    $( "body" ).append $("#equation_panel")
    $( this ).parent().hide 'easeInElastic', -> $( this ).remove()

