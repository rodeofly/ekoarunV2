
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
  pattern_terme = /\(([\+\-]?\d+(?:\/\d+)*)\)(\w+)\^(\d+)*/g
  foo = s.match(pattern_terme)
  
  if (foo? and foo[0] is s)
    foo = regex.exec pattern_terme
    fracString = foo[0][1..]
    symbol = foo[1]
    foo = if foo[1] then [foo[0][1..], ] else [foo[0][1..]]
  else
    alert "Vous devriez effacer l'invite de commande et envisager quelquechose de mieux pondéré...ok !?"
    
class Monome
  constructor: ($monome) ->
    if $monome
      @id = "##{$monome.attr('id')}"
      @parent_id = "##{$( @id ).parent().attr('id')}"
      @fraction = fracString_to_frac $( @id ).attr("data-fraction")
      @symbol = $( @id ).attr("data-symbol")
      @power = parseInt( $( @id ).attr("data-power") )
    else
      @id = "##{unique_id++}"
      @power = 1
  
  clone : () -> 
    m = new Monome()
    m.id        = "##{unique_id++}"
    m.parent_id = @parent_id
    m.fraction  = @fraction
    m.symbol    = @symbol
    m.power     = @power
    return m
     
  randomize: (@symbol, @power) ->
    [min,max] = [-10,10]
    coeff = Math.floor(Math.random() * (max-min+1)) + min
    @fraction = new Fraction coeff,1

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
  
  monome_insert: (monome) -> (new Monome()).insert(@id)
  
  monomesString_insert: (membre) -> 
    for monomeString in membre
      (new Monome()).insert_from_string(@id, monomeString)
  
  toString : () ->
    s = @symbol 
    string = ""
    $( @id ).children().each ->
      if $(this).is "ul"
        string += "operateur"
      else
        m = new Monome $(this)
        string += "#{s}#{m.toString()}"
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
    op = new Operateur("##{$(this).attr('id')}")
        
    $( "#{op.id} > li.monome" ).droppable accept : "#{op.id} > li.monome", hoverClass : "state-hover", activeClass: "li-state-active", drop: (event, ui) ->
      event.stopImmediatePropagation()
      console.log "woot"
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
            
    $( "#{op.id} > ul.operateur" ).droppable accept : "#{op.id} > li.monome, #{op.id} > ul.operateur", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->
      console.log "webeet1"
      op2 = new Operateur("##{$(this).attr('id')}")
      if ui.draggable.is "ul"
        op3 = new Operateur "##{ui.draggable.attr('id')}"
        console.log "webeet2 : #{op3.type}"
        switch op3.type
          when "multiplication"
            
            str2 = op2.toString()
            str3 = op3.toString()
            console.log "webeet3"
            regex = /([+-]?\d+(?:\/\d+)?)[.](.*)/
            match2 = regex.exec str2
            match3 = regex.exec str3 
            console.log "#{match2[2]} is #{match3[2]}"
            if (match2.length is 3 and match2[2] is match3[2] )
              console.log "webeet3"
              m2 = new Monome $( op2.id ).children("li:first")
              m3 = new Monome $( op3.id ).children("li:first")
              m2.fraction.ajouter m3.fraction
              $( op3.id ).remove()
              m2.update()
            
      else
        m = new Monome ui.draggable 
        op2 = new Operateur("##{$(this).attr('id')}")
        switch op.type
          when op2.type then $( op2.id ).append $( m.id )
          when "addition"
            if op2.type is "multiplication"
              op3 = new Operateur( op2.id , op.symbol )
              m.clone().insert op3.id
              $( m.id ).remove()
          when "multiplication" 
            if op2.type is "addition"
              $( op2.id ).children( "ul, li" ).each ->
                op3 = new Operateur( "##{$(this).attr('id')}" , op.symbol )
                m.clone().insert op3.id
              $( m.id ).remove()
      megateuf()   
    
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
  
generate_equation = (unknown=2, factor_length=2, depth=2, min = -10, max = 10) ->
  id = unique_id++
  signe = signes[Math.floor Math.random() * signes.length]
  html =
  """
  <div id='equation_#{id}' class='equation' >
      <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>x</button>    
      <p id='solution_#{id}'></p>
      <ul id='fake' data-symbol="*"></ul>
      <span id='signe_#{id}' class='signe'>#{signe}</span>
  </div>
  """
  $( "#equations_div" ).append html
  #$("#equations_div" ).sortable()
   
  Array::shuffle ?= ->
    if @length > 1 then for i in [@length-1..1]
      j = Math.floor Math.random() * (i + 1)
      [@[i], @[j]] = [@[j], @[i]]
      return this
    
  alphabet = (['1', 'a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'][0..unknown]).shuffle()
  console.log alphabet
  create_equation_membre = ->  
    (operateur = new Operateur("#fake", "+"))
    $( operateur.id ).append( $( "#fake" ) )  
    for j in [1..factor_length]
      op = new Operateur("#fake", "+")
      for j in [1..unknown]
        m = new Monome()
        m.randomize((alphabet.shuffle())[j],1) 
        m.insert op.id
      $( operateur.id ).append( $( "#fake" ) ) 
    $( "#fake" ).remove()
    $( operateur.id ).find("ul").each ->
      op = new Operateur("##{$(this).attr('id')}", "*")
      for j in [1..factor_length]
        m = new Monome()
        m.randomize((alphabet.shuffle())[j],1) 
        m.insert op.id
  
  create_equation_membre()  
  $( "#equation_#{id}" ).append "<ul id='fake' data-symbol='*'></ul>"
  create_equation_membre()  
  megateuf()
  
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
        #$("#equations_div" ).sortable()
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
  $('body').on "click", "li", (event) ->
    m = new Monome $( this )
    op = new Operateur m.parent_id
    # Addition
    switch op.type
      when "addition"
        if m.fraction.numerateur is 0
          switch $( "#{m.id}" ).siblings().length
            when 0
              m.fraction.numerateur
              m.update()
            else $( "#{m.id}" ).remove()                    
      when "multiplication"
        switch m.fraction.numerateur/m.fraction.denominateur
          when 1
            switch $( "#{m.id}" ).siblings().length
              when 0
                m.fraction.numerateur = 1
                m.update()
              else $( "#{m.id}" ).remove() if m.symbol is "1"
          when 0
            $( op.id ).empty()
            zero = new Monome()
            [zero.symbol, zero.fraction ] = [ "1", new Fraction 0, 1 ]
            zero.insert op.id        
    $( "#equation_string").val m.toString() # Sinon on l'affiche dans la console
    megateuf()
  
  # selectionner un terme
  #$('body').on "click", "ul", (event) ->
    
  
  $('body').on "dblclick", "ul", (event) ->
    Array::unique = ->
	    output = {}
	    output[@[key]] = @[key] for key in [0...@length]
	    value for key, value of output
    op = new Operateur "##{$(this).attr('id')}"
    switch $( op.id ).children("ul").length
      when 0
        switch op.type
          when "multiplication"
            [index, symbols] = [{}, [] ]
            index["1"] = new Fraction 1, 1
            
            $( op.id ).children().each ->
              current = new Monome $(this)
              if current.symbol isnt "1"
                index[ current.symbol ] = if (index[ current.symbol ]?) then (current.power + index[ current.symbol ]) else current.power
              index[ "1" ] = current.fraction.multiplier( index[ "1" ] )
            console.log index
            $( op.id ).empty()
            Object.keys(index).sort().forEach (symbol, i) ->
              m = new Monome()
              m.symbol = symbol
              if symbol is "1"
                m.fraction = index[ "1" ]
              else
                m.fraction = new Fraction 1, 1 
                m.power = index[ symbol ]
              m.insert op.id
              

  
  

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

  $( "body" ).on "click", ".deleteButton", (event) ->
    event.stopPropagation() # important pour ne pas perdre #equation_panel
    $( "body" ).append $("#equation_panel")
    $( this ).parent().hide 'easeInElastic', -> $( this ).remove()

