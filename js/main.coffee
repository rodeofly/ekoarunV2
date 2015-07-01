Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output
Array::shuffle ?= ->
  if @length > 1 then for i in [@length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [@[i], @[j]] = [@[j], @[i]]
  return this
  
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
amount_variable = 1
amount_facteur = 2
amount_minimax = 2
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
      if n? and d? then foo = new Fraction( n,d) else alert "Erreur : fracString_to_frac, n is #{n} and d is #{d} !"
    when 1
      n = parseInt(foo[0])
      if n? then foo = new Fraction(n,1) else alert "Erreur : fracString_to_frac, n is #{n} !"
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
    if @numerateur/@denominateur is 1
      html = "<span class='plus'>&plus;</span>"
    else if @numerateur/@denominateur is -1
      html = "<span class='moins'>&minus;</span>"
    else if @denominateur is 1
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
  pattern_terme = /([\+\-]?\d+(?:\/\d+)*)[.+](\w+)\^(\d+)*/g
  foo = s.match(pattern_terme)
  if (foo? and foo[0] is s)
    foo = regex.exec pattern_terme
    fracString = foo[1]
    symbol = foo[2]
    power = foo[3]
  else
    alert "Vous devriez effacer l'invite de commande et envisager quelquechose de mieux pondéré...ok !?"

get_monome = ($monome) ->
  if ( $monome.is("[data-fraction]") and $monome.is("[data-symbol]") and $monome.is("[data-power]") )
    m = new Monome()
    m.id = "##{$monome.attr('id')}"
    m.parent_id = "##{$( m.id ).parent().attr('id')}"
    m.fraction = fracString_to_frac $( m.id ).attr("data-fraction")
    m.symbol = $( m.id ).attr("data-symbol")
    m.power = parseInt( $( m.id ).attr("data-power") )
    return m
  else alert "get_monome did not work !"
    
class Monome
  constructor: (@fraction, @symbol, @power) ->
    @id = "##{unique_id++}"
    @fraction ?= new Fraction(1,1)
    @symbol ?= "1"
    @power ?= 1
    
  clone : () -> 
    m = new Monome()
    m.id = "##{unique_id++}"
    m.parent_id = @parent_id
    m.fraction = @fraction
    m.symbol = @symbol
    m.power = @power
    return m
     
  randomize: (@symbol, @power) ->
    min = -amount_minimax
    coeff = Math.floor(Math.random() * (amount_minimax-min+1)) + min
    @fraction = new Fraction(coeff,1)
    return this

  update : () ->
    @power = 1 if (@symbol is "1")
    $( @id ).attr "data-fraction", @fraction.toString()
    $( @id ).attr "data-power", @power
    $( @id ).html( this.html_content() )
          
  irreductible : () -> 
    @fraction.irreductible()
    this.update()
  
  remove : () -> $( @id ).remove()
  
  html_content : () ->
    if ( (@symbol isnt "1") or ( (Math.abs(@fraction.numerateur/@fraction.denominateur) is 1 ) ) )
      symbol_div =  "<span class='symbol'>#{@symbol}</span>"
    else
      symbol_div =  ""  
    power_div = if (@power is 1) then "" else "<sup class='power'>#{@power}</sup>"
    html = "#{@fraction.toHtml()}#{symbol_div}#{power_div}"
    
  insert: (id) ->
    $( id ).append "<li id='#{@id[1..]}' class='monome item' data-fraction='#{@fraction}' data-symbol='#{@symbol}'  data-power='#{@power}'></li>"
    this.update()
    
  insert_from_string : ( @equation_id, monomeString) ->
    m = monomeString.split(".")
    @fraction = fracString_to_frac m[0]
    alert @fraction
    if m.length > 1
      m = m[1].split("^")
      [ @symbol, @power ] = [ m[0], m[1] ]
    else
      [ @symbol, @power ] = [1, 1]
    (new Monome()).insert( @equation_id )
      
  ajouter: (monome) ->
    if (@symbol is monome.symbol)
      @fraction.ajouter monome.fraction
    else
      alert "On ne mélange pas symboles & chiffres !"
    return this
  
  toString: () -> return "#{@fraction.toString()}.#{@symbol}^#{@power}"
  
  toArray: () -> monomeString_to_array(this.toString())
  
  toHtml: () ->
    html = "<li id='#{@id[1..]}' class='monome item' data-fraction='#{@fraction.toString()}' data-symbol='#{@symbol}' data-power='#{@power}'><span class='monome_html'>#{this.html_content()}</span></li>"
  

###################################################################################################
###################################################################################################
###################################################################################################
#Operateur
stringIdToString = (stringId) ->
  stringId.replace /(\#\d+)/g, (match, id, offset, string) ->
    console.log $(id).id
    get_monome( $(id) ).toString()

get_operateur = ( $operateur ) ->
  if ( $operateur.is("[data-symbol]") and $operateur.is("[data-type]") and $operateur.is("[data-compacted]") )
    o = new Operateur()
    o.id        = "##{$operateur.attr('id')}"
    o.parent_id = "##{$( o.id ).parent().attr('id')}"
    o.type      = $( o.id ).attr( "data-type" )
    o.symbol    = $( o.id ).attr( "data-symbol" )
    o.compacted = $( o.id ).attr( "data-compacted" )
    return o
  else alert "get_operateur did not work !"
     
class Operateur
  constructor: (@symbol, @compacted) ->
    classe = {"*": "multiplication", "+" : "addition"}
    @id         = "##{unique_id++}"
    @symbol    ?= "+"
    @type       = classe[@symbol]
    @compacted ?= false
  
  toHtml : () -> html = "<ul id='#{@id[1..]}' class='operateur #{@type} item' data-symbol='#{@symbol}' data-type='#{@type}' data-compacted='#{@compacted}'></ul>"
  
  clone : () ->
    o = new Operateur()
    o.id        = "##{unique_id++}"
    o.parent_id = @parent_id
    o.type      = @type
    o.symbol    = @symbol
    o.compacted = @compacted
    return o
  
  monomesString_insert: (membre) -> 
    for monomeString in membre
      (new Monome()).insert_from_string(@id, monomeString)
    
  toStringId : () -> 
    symbol = @symbol
    string = ""
    $( @id ).children().each ->
      if $(this).is "ul"
        m = get_operateur( $( this ) )
        string += "#{symbol}[#{m.toStringId()}]"
      else
        m = get_monome( $( this ) )
        string += "#{symbol}#{m.id}"
    return string[1..]
    
  
###################################################################################################
###################################################################################################
###################################################################################################
#Équation
megateuf = () ->
  $( "ul.operateur" ).each -> 
    if ( ($(this).children().length is 1) and ( ( not $(this).parent().hasClass("equation") ) or (  $(this).siblings().length > 0 ) ) ) # ((Operateur | li))
      $(this).contents().unwrap()
    else if ( $(this).attr("data-symbol") is $(this).parent().attr("data-symbol") ) #(+ (+) ) | (+ (+) )
      $(this).contents().unwrap() 
  


  $( "ul.operateur" ).each ->   
    op = get_operateur( $(this) )
        
    $( "#{op.id} > li.monome" ).droppable accept : "#{op.id} > li.monome", hoverClass : "state-hover", activeClass: "li-state-active", drop: (event, ui) ->
      event.stopImmediatePropagation()
      console.log "woot"
      m1 = get_monome( ui.draggable )   
      m2 = get_monome( $( this ) )
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
            m1.fraction = new Fraction( 1,1)
            m2.update()
            m1.update()         
      megateuf()
    
           
    $( "#{op.id}.multiplication > ul.addition" ).droppable accept : "#{op.id} > li.monome, #{op.id} > ul.operateur", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->
      op2 = get_operateur( $( this ) )
      if ui.draggable.is "ul"  # Distribution d'un facteur sur une addition
        op3 = get_operateur( ui.draggable )
        switch op3.type
          when "addition"
            console.log "woor"
            $( "#{op2.id} > ul.operateur, #{op2.id} > li.monome").each () -> 
              op4 = new Operateur( "*" )
              $( op2.id ).append( op4.toHtml() )
              $( op4.id ).append( $( this ) )
              
              clone = new Operateur( op3.symbol ) 
              $( this ).after clone.toHtml()
              $( clone.id ).html( $( op3.id ).html() )
              $( clone.id ).find('[id]').each -> $( this ).attr("id", "#{unique_id++}" )
              
        $( op3.id ).remove()
              
      

      else
        m = get_monome( ui.draggable )
        switch op.type
          when op2.type then $( op2.id ).append $( m.id )
          when "addition"
            op3 = new Operateur( "+" )
            console.log( "woot" )
            $( op2.id ).wrap( op3.toHtml() )
            m.clone().insert( op3.id ) if op2.type is "multiplication"
          when "multiplication"
            console.log( "waaot" )
            $( op2.id ).children( "ul, li" ).each -> 
              op3 = new Operateur( "*" ) 
              $( this ).wrap op3.toHtml()
              m.clone().insert( op3.id ) if op2.type is "addition"
        $( m.id ).remove()
      megateuf()
      
    $( "#{op.id}.addition > ul.multiplication" ).droppable accept : "#{op.id} > li.monome, #{op.id} > ul.multiplication", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->   
      op2 = get_operateur( $( this ) )
      if ui.draggable.is "ul"
        op3 = get_operateur( ui.draggable )
        str2 = stringIdToString( op2.toStringId() ) 
        str3 = stringIdToString( op3.toStringId() )    
        [match2, match3 ] = [/([-+]?\d+(?:\/\d+)?)[\.+](.*)/g.exec( str2 ), /([-+]?\d+(?:\/\d+)?)[\.+](.*)/g.exec( str3 ) ]
        if ( match2? and match3? and (match2.length is 3) and (match3.length is 3 ) and (match2[2] is match3[2]) )
          console.log $( op2.id ).children("li:first").attr('id')
          console.log $( op3.id ).children("li:first").attr('id')
          [ m2, m3 ] = [ get_monome( $( op2.id ).children("li:first") ), get_monome( $( op3.id ).children("li:first") ) ]
          m2.fraction.ajouter m3.fraction
          $( op3.id ).remove()
          m2.update()
          
  #$( ".equation > ul.operateur" ).droppable accept : ".equation > ul.operateur > ul.operateur", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->
  #$( ".equation > ul.multiplication" ).droppable accept : ".equation > ul.operateur", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->
    
      
    $( "ul.operateur, li.monome" ).draggable revert : true
generate_equation_string = (n, min = -10, max = 10) ->
  equation = {}
  equation["signe"] = signes[Math.floor Math.random() * signes.length]
  for side in ["gauche", "droite"]
    str= ""
    for [1..n]
      coeff = Math.floor(Math.random() * (max-min+1)) + min
      toss = Math.floor(Math.random() * (2)) - 1
      str += if toss is 0 then "+(#{coeff})1" else "+(#{coeff})x "
    equation[side] = str[1..] 
  equation = "#{equation['gauche']} #{equation['signe']} #{equation['droite']}"
  
generate_equation = () ->
  id = unique_id++
  signe = signes[Math.floor Math.random() * signes.length]
  html =
  """
  <div id='equation_#{id}' class='equation' >
       
      <p id='solution_#{id}'></p>

      <span id='signe_#{id}' class='signe'>#{signe}</span>

      <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>x</button>   
  </div>
  """
  $( "#equations_div" ).append html
  #$("#equations_div" ).sortable()
  alphabet = (['1', 'a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'][0..amount_variable])
  console.log alphabet
  create_equation_membre = ( place ) ->  
    op1 = new Operateur( "+" )
    if place is "before"
      $( "#signe_#{id}" ).before( op1.toHtml() )
    else
      $( "#signe_#{id}" ).after( op1.toHtml() )
      
    for i in [1..amount_facteur]
      op2 = (new Operateur "*" )
      $( op1.id ).append( op2.toHtml() )
      for j in [1..amount_minimax]
        op3 = new Operateur( "+" )
        $( op2.id ).append( op3.toHtml() )
        for k in alphabet
          m = new Monome()
          m.randomize( k ,1).insert( op3.id )
          
  create_equation_membre("before")  
  create_equation_membre("after")  
  megateuf()

ajouter_membre = (string) ->
  id = get_focused_id()
  if (id )
    $( "#equation_#{id} > .operateur" ).each ->  
      op = new Operateur( "+")
      $(this).append( op.toHtml() )
      op.monomesString_insert( string )

multiplier_distribuer_membre = (facteur) ->
  id = get_focused_id()
  if (id and facteur.denominateur)
    $( "#equation_#{id} > ul > li.monome").each ->
      m = get_monome( $( this ) )
      m.fraction.multiplier facteur
      m.update()

multiplier_factoriser_membre = (string) ->
  id = get_focused_id()
  if (id )
    $( "#equation_#{id} > .operateur" ).each ->
      op = new Operateur( "*" )
      $(this).wrap op.toHtml() 
      op.monomesString_insert( string )

get_focused_id = () -> id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
  
operation_sur_equation = (mode, id) ->
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
  
###################################################################################################
###################################################################################################
###################################################################################################
# Init
  do once = () ->
    $( "#toggle_help" ).on "click", -> $( "#help, #aside, #footer" ).toggle()
###################################################################################################
###################################################################################################
###################################################################################################  
  $( ".operateur" ).on "click", ->
    if (($(this).children().length < 2) or ($(this).attr('data-symbol') is $(this).parent().attr('data-symbol')) )
      $(this).unwrap() 
  $( "#generer_equation" ).on "click", -> $( "#equation_string" ).val generate_equation_string Math.floor(10*Math.random())+1
  
 
         

  # effacer l'invite _ commande
  $("#effacer_equation_string").on "click", ->  $( "#equation_string" ).val( "" )
  
  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", (event) ->
    $("#equation_#{id}.focus ul > .monome").addClass( "selected" ) if id = get_focused_id()
  
  #Simplifier les fractions selectionnées d'une équation
  monome_irreductible = ($monome) -> (m = get_monome($monome)).irreductible()
  $( "body" ).on "dblclick", ".monome", () -> monome_irreductible $(this)
  $( "body" ).on "click", ".simplifier_les_monomes", () -> if id = get_focused_id() then $( "#equation_#{id} > ul > li.selected" ).each -> monome_irreductible $(this)
   
  # selectionner un terme
  $('body').on "click", "li", (event) ->
    event.stopPropagation()
    m = get_monome( $( this ) )
    op = get_operateur $( m.parent_id )
    
    switch op.type # a quel operateur appartient ce monome ?
      when "addition"
        if m.fraction.numerateur is 0 # si c'est un zero mais que c'est le dernier on le garde sinon on l'enleve
          switch $( "#{m.id}" ).siblings().length
            when 0 then m.update()
            else $( "#{m.id}" ).remove()                    
      when "multiplication"
        switch m.fraction.numerateur/m.fraction.denominateur 
          when 1  # si c'est un 1 mais que c'est le dernier on le garde sinon on l'enleve
            switch $( "#{m.id}" ).siblings().length
              when 0
                m.fraction.numerateur = 1
                m.update()
              else $( "#{m.id}" ).remove() if m.symbol is "1"
          when 0  # si c'est un zero il rend l'operateur nul
            $( op.id ).empty()
            zero = new Monome()
            [zero.symbol, zero.fraction ] = [ "1", new Fraction( 0, 1) ]
            zero.insert op.id        
    $( "#equation_string").val m.toString() # Sinon on l'affiche dans la console
    megateuf()
  
  # selectionner un terme
  $('body').on "click", "ul", (event) ->
    event.stopPropagation()
    op = get_operateur( $( this ) )
    $( "#equation_string").val op.toStringId()
    
  
  $('body').on "dblclick", "ul.operateur.multiplication", (event) ->
    op = get_operateur( $( this ) )
    if $( "#{op.id} > ul.operateur" ).length is 0 #il n'y a que des monomes
      [index, symbols] = [{}, [] ]
      index["1"] = new Fraction( 1, 1)    
      $( op.id ).children().each ->
        current = get_monome( $( this ) )
        if current.symbol isnt "1"
          index[ current.symbol ] = if (index[ current.symbol ]?) then (current.power + index[ current.symbol ]) else current.power
        index[ "1" ] = current.fraction.multiplier( index[ "1" ] )
      $( op.id ).empty()
      Object.keys(index).sort().forEach (symbol, i) ->
        (m = new Monome()).symbol = symbol
        m.fraction = if (i is 0) then index[ "1" ] else new Fraction( 1, 1 )
        m.power = index[ symbol ]
        m.insert op.id
      if $( "#{op.id} > li.monome" ).length > 1
        [ m1, m2 ] = [ get_monome( $( "#{op.id} > li.monome:first" ) ), get_monome( $( "#{op.id} > li:nth-child(2)" ) )]
        console.log m1, m2
        m2.fraction = m1.fraction
        m2.update()
        m1.remove()

  $('body').on "dblclick", "ul.operateur.addition", (event) ->
    op = get_operateur( $( this ) )
    if $( "#{op.id} > ul.operateur" ).length is 0 #il n'y a que des monomes
      coeffs = {}
      coeffs["1"] = new Fraction 0, 1
      $( "#{op.id} > li.monome" ).each -> 
        m = get_monome( $( this ) )        
        coeffs[  m.symbol   ] = if coeffs[m.symbol]? then m.fraction.ajouter coeffs[m.symbol] else m.fraction
        m.remove()
      for symbol, fraction of coeffs
        m = new Monome()
        m.fraction = fraction
        m.symbol = symbol
        m.insert( op.id )

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
  
  $( "body" ).on "click", ".deleteButton",          () -> $( this ).parent().hide 'easeInElastic', -> $( this ).remove()
  $( "body" ).on "click", ".multiplier_distribuer", () -> operation_sur_equation( "multiplier_distribuer" )   
  $( "body" ).on "click", ".multiplier_factoriser", () -> operation_sur_equation( "multiplier_factoriser" )   
  $( "body" ).on "click", ".diviser",               () -> operation_sur_equation( "diviser" )
  $( "body" ).on "click", ".ajouter",               () -> operation_sur_equation( "ajouter" )
  $( "body" ).on "click", ".retrancher",            () -> operation_sur_equation( "retrancher" )
  $( "body" ).on "click", ".equation",              () ->
    $( ".focus" ).toggleClass("focus")
    $( this ).toggleClass("focus") 
  
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
   
   
  $( "#slider-variable" ).slider
    range: "max"
    min   : 0 
    max   : 10
    step  : 1
    value : amount_variable
    slide : ( event, ui ) -> $( "#amount-variable" ).html( amount_variable = ui.value )
  $( "#amount-variable" ).html(amount_variable)
  
  $( "#slider-facteur" ).slider
    range: "max"
    min   : 1
    max   : 10
    step  : 1
    value : amount_facteur
    slide : ( event, ui ) -> $( "#amount-facteur" ).html( amount_facteur = ui.value )
  $( "#amount-facteur" ).html(amount_facteur)
  
  $( "#slider-minimax" ).slider
    range: "max"
    min   : 1
    max   : 5
    step  : 1
    value : amount_minimax
    slide : ( event, ui ) -> $( "#amount-minimax" ).html( amount_minimax = ui.value )
  $( "#amount-minimax" ).html(amount_minimax)
    
