
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

fracString_to_frac = (value) ->
  console.log "fracString_to_frac(#{value}) starts !" if debug
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
###################################################################################################
###################################################################################################
################################################################################################### 
# Monomes

class Monome
  constructor: (id) ->
    if id?
      @id = "##{id}"
      @equation_id = $( @id ).parent().attr("id").split("_")[2]
      @side = if $( @id ).hasClass( "gauche" ) then "gauche" else "droite"
      @fraction = fracString_to_frac $( @id ).attr("data-value")
      @type = $( @id ).attr("data-type")
      @symbol = if @type is "symbol" then $( @id ).attr("data-symbol") else ""
    else
      @id = "#monome_#{unique_id++}"
 
  irreductible : () -> @fraction.irreductible()
  
  remove : () -> $( @id ).remove()
  
  update : () ->
    $( @id ).attr "data-value", @fraction.toString()
    switch @type
      when "symbol"
        if @fraction.numerateur*@fraction.denominateur in [-1,1]
          if @fraction.numerateur/@fraction.denominateur is 1
            html = "<span class='droppable'><span class='plus' >+      </span><span>#{@symbol}</span></span>"
          else html = "<span class='droppable'><span class='moins'>&minus;</span><span>#{@symbol}</span></span>"
        else html = "<span class='droppable'>#{@fraction.toHtml()}<span>#{@symbol}</span></span>"                   
      else html = "<span class='droppable'>#{@fraction.toHtml()}</span>"
    $( @id ).html(html).droppable
      accept: "#membre_#{@side}_#{@equation_id} > li"
      hoverClass: "ui-state-hover"
      drop: (event, ui) -> 
        m1 = new Monome ui.draggable.attr("id")
        m2 = new Monome $( this ).attr("id")
        if ( (m1.type is m2.type) and ( (m1.type is "rationnel") or (m1.symbol is m2.symbol) ) )
          m2.fraction.ajouter m1.fraction
          ui.draggable.hide duration: "slow", easing: "easeInCirc", complete: -> 
            m1.remove()
            m2.update()
        else
          alert "On ne mélange pas symboles & chiffres !"
  
  cross_over: () ->
    @side = if $( @id ).hasClass( "gauche" ) then "gauche" else "droite"
          
  insert: (@equation_id, @side, @fraction, @symbol) ->
    @type = if @symbol? then "symbol" else "rationnel"
    html = "<li id='#{@id[1..]}' class='monome #{@side}' data-value='#{@fraction}' data-type='#{@type}' "
    html += if @symbol? then "data-symbol='#{@symbol}'></li>" else "></li>"
    $( "#membre_#{@side}_#{@equation_id}" ).append html
    this.update()  
      
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
  
  toHtml: () ->
    html = "<li id='#{@id[1..]}' class='monome #{@side}' data-value='#{@fraction.toString()}' data-type='#{@type}' data-symbol='#{@symbol}'><span class='monome_html'>"
    switch @type
      when "symbol"
        if @fraction.numerateur*@fraction.denominateur in [-1,1]
          if @fraction.numerateur/@fraction.denominateur is 1
            html +=  "<span class='droppable'><span class='plus'>+</span><span>#{@symbol}</span></span></li>"
          else html +=  "<span class='droppable'><span class='moins'>&minus;</span><span>#{@symbol}</span></span></li>"
        else html += "#{@fraction.toHtml()}<span>#{@symbol}</span></span></li>"                   
      when "rationnel" then html += "#{@fraction.toHtml()}</span></li>"

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

###################################################################################################
###################################################################################################
###################################################################################################
#Équation
# Afficher le contenu des termes de l'equation
monomesString_insert = (membre,side,id) ->
  for monomeString in membre
    m = monomeString.split(")")
    fraction = fracString_to_frac m[0][1..]
    if m[1] then (new Monome()).insert( id, side, fraction, m[1]) else (new Monome()).insert( id, side, fraction)

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
  
obtenir_la_solution = (id) ->
  if $( "#equation_#{id} > ul.membre_gauche > li").length is 1 and $( "#equation_#{id} > ul.membre_droite > li").length is 1
    $li_gauche = $( "#equation_#{id} > ul.membre_gauche > li")
    $li_droite = $( "#equation_#{id} > ul.membre_droite > li")
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

ajouter_membre = (id, array, sign) ->
  fraction = fracString_to_frac array[0]
  fraction.multiplier fracString_to_frac "#{sign}"
  switch array.length
    when 1 then (new Monome()).insert( id, side, fraction) for side in ["gauche", "droite"]
    when 2 then (new Monome()).insert( id, side, fraction, array[1]) for side in ["gauche", "droite"]     
    else alert "erreur dans ajouter_membre #{fraction}"

multiplier_membre = (facteur,id) ->
  if facteur.numerateur
    if facteur.numerateur/facteur.denominateur < 0 then $("#signe_#{id}").text changementSens[$("#signe_#{id}").text()]
    $( "#equation_#{id} > ul > li.monome").each ->
      m = new Monome( $( this ).attr( "id") )
      m.fraction.multiplier facteur
      m.update()

get_focused_id = () -> id = if $( ".focus" ).attr("id") then $( ".focus" ).attr("id").split("_")[1] else alert "Selectionner une équation !"
  
operation_sur_equation = (mode, id) ->
  if $( "#equation_string" ).val().slice(-1) in liste_des_chiffres then $( "#equation_string" ).val($( "#equation_string" ).val().concat ')')
  id = get_focused_id()
  array = monomeString_to_array $( "#equation_string" ).val()
  if (id? and array?)
    switch array.length
      when 1
        facteur = fracString_to_frac array[0]
        switch mode
          when "diviser"
            facteur.inverse()
            multiplier_membre(facteur,id)
          when "multiplier_distribuer" then multiplier_membre facteur,id
          when "retrancher" then ajouter_membre id, array, -1
          when "ajouter"    then ajouter_membre id, array, 1
      when 2 
        switch mode
          when "retrancher" then ajouter_membre id, array, -1
          when "ajouter"    then ajouter_membre id, array, 1
          else alert "On ne peut pas encore faire cela !"    
  else alert "Poids surement mal formé !" 
###################################################################################################
###################################################################################################
###################################################################################################  
# On Dom Ready !
$ ->
###################################################################################################
###################################################################################################
###################################################################################################
#Equation CRUD
  $( "#generer_equation" ).on "click", -> $( "#equation_string" ).val generate_equation_string Math.floor(10*Math.random())+1   

  $('body').on "click", ".equation", () ->
    $( ".focus" ).toggleClass("focus")
    $( "#equation_operator").show().appendTo $( this ).toggleClass("focus")
  
  # effacer une equation
  $( "body" ).on "click", ".deleteButton", (event) ->
    event.stopPropagation() # important pour ne pas perdre #equation_operator
    $( "body" ).append $("#equation_operator") if $( this ).hasClass "focus"
    $( this ).parent().hide 'easeInElastic', -> $( this ).remove()
  
  $( "#inserer_equation" ).on "click", () ->
    if s = $( "#equation_string" ).val()
      if s.slice(-1) in liste_des_chiffres then $( "#equation_string" ).val(s + ')')
      s = $( "#equation_string" ).val().replace(/\s+/g, '') # On récupère l'equation et on enlève tous les whitespaces \s+
      # regex digest !
      pattern_equation = /((?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*)(?:\+(?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*))*)([<≤=≥>])((?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*)(?:\+(?:\([\+\-]*\d+[\/\d+]*\)(?:\w+²?)*))*)/g
      foo = s.match(pattern_equation)
      if ((foo isnt null) and (foo[0].length is s.length))
        match = pattern_equation.exec(s)
        signe = match[2]
        mdg = match[1].split("+")
        mdd = match[3].split("+")   
        id = unique_id++
        html =
        """
        <div id='equation_#{id}' class='equation' >
            <button id='deleteButton_#{id}' class='deleteButton' title='Supprimer cette équation'>x</button>
            <ul id='membre_gauche_#{id}' class='membre_gauche'></ul>"
            <span id='signe_#{id}' class='signe'>#{signe}</span>"
            <ul id='membre_droite_#{id}' class='membre_droite'></ul>"
            <p id='solution_#{id}'></p>
        </div>
        """
        $( "#equations_div" ).append html
        monomesString_insert mdg, "gauche", id 
        monomesString_insert mdd, "droite", id
          
        for side in ["gauche", "droite"]
          opposite_side = if side is "gauche" then "droite" else "gauche"
          $( ".membre_#{side}" ).each ->
            id = $( this ).attr("id").split("_")[2]      
            $( "#membre_#{side}_#{id}" ).sortable
              connectWith: "#membre_#{opposite_side}_#{id}"
              receive : (event, ui) ->
                m = new Monome ui.item.attr("id")
                m.fraction.oppose()
                ui.item.replaceWith m.toHtml()
                $( m.id ).toggleClass("gauche droite")
                for s in ["gauche", "droite"]
                  if $( "#membre_#{s}_#{id} > li" ).length is 0 then (new Monome()).insert id, s, new Fraction(0,1)
        $("#equations_div" ).sortable()
        $( "#equation_#{id}" ).trigger "click" 
      else
        alert "Vérifier que l'équation est correctement formatée"

###################################################################################################
###################################################################################################
###################################################################################################
#Le petit panel tactile
  do once = () ->
    $( "#toggle_help" ).on "click", -> $( "#help, #aside, #footer" ).toggle()
    $( "#help, #aside, #footer" ).toggle()
    for char in liste_des_variables.concat liste_des_operateurs.concat ["/"].concat liste_des_signes
      $("#equation_panel").append("<button id='var_#{char}' class='panel_touch'>#{char}</button>")
    $("#equation_panel").append("<br>")
    for char in liste_des_chiffres.concat ["&leftarrow;"]
      $("#equation_panel").append("<button id='var_#{char}' class='panel_touch'>#{char}</button>")
    $( "button" ).button()
    #$( "#equation_operator").draggable()
 
  #effacer l'invite _ commande
  $("#effacer_equation_string").on "click", ->  $( "#equation_string" ).val( "" )  
  
  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", (event) ->
    $("#equation_#{id}.focus ul > .monome").addClass( "selected" ) if id = get_focused_id()
  
  monome_irreductible = (id) ->
    (m = new Monome(id)).irreductible()
    $( m.id ).replaceWith m.toHtml()
  
  #Simplifier les fractions selectionnées d'une équation
  $( "body" ).on "dblclick", ".monome", () -> monome_irreductible $(this).attr("id")
  $( "body" ).on "click", ".simplifier_les_monomes", () -> 
    if id = get_focused_id() then $( "#equation_#{id} > ul > li.selected" ).each -> monome_irreductible $(this).attr("id")
  
  # selectionner un terme
  $('body').on "click", "li", (event) ->
    m = new Monome $( this ).toggleClass("selected").attr("id")
    if m.fraction.numerateur is 0 # Si c'est un zero il y a traitement particulier
      switch $( this ).siblings().length
        when 0
          m.type = "rationnel"
          m.fraction.numerateur = 0
          m.update()
        else $( this ).remove()  
    else $( "#equation_string").val m.toString()#Sinon on l'affiche dans la console
         
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
  $( "body" ).on "click", ".diviser",    () -> operation_sur_equation( "diviser" )
  $( "body" ).on "click", ".ajouter",    () -> operation_sur_equation( "ajouter" )
  $( "body" ).on "click", ".retrancher", () -> operation_sur_equation( "retrancher" )      
  # effectuer la somme, par membre, _s termes selectionnés
  $( "body" ).on "click", ".sommationMonome", () -> 
    if id = get_focused_id()
      for side in ["gauche", "droite"]
        membre = "#membre_#{side}_#{id}"
        selected = "#{membre} > .#{side}.selected"
        coeffs = {}
        coeffs["rationnel"] = new Fraction 0, 1
        console.log "sommation_par_membre : #{selected} (#{$( selected ).length})" if debug
        $( selected ).each ->
          m = new Monome $( this ).attr("id")
          switch m.type
            when "symbol"
              coeffs[ m.symbol ] = if coeffs[m.symbol]? then m.fraction.ajouter coeffs[m.symbol] else m.fraction
            when "rationnel" then coeffs[ "rationnel" ] = m.fraction.ajouter coeffs[ "rationnel" ]     
        for symbol, fraction of coeffs
          switch symbol
            when "rationnel" then (new Monome()).insert id, side, fraction
            else (new Monome()).insert id, side, fraction, "#{symbol}"
        $( selected ).remove()
             
  $( "body" ).on "click", ".copier", () ->
    id = get_focused_id()    
    activer_copier_symbole = $( "#equation_#{id} > ul.membre_gauche > li").attr("data-symbol")
    activer_copier_contenu = $( "#equation_#{id} > ul.membre_droite > li")
    alert "symbole copié : #{activer_copier_symbole}"
 
  $( "body" ).on "click", ".coller", () ->
    check_substitute = (side,id) ->
      #console.log "#membre_#{side}_#{id} > li : #{$( '#membre_#{side}_#{id} > li').length} élément(s)"
      $( "#membre_#{side}_#{id} > li").each ->
        #alert activer_copier_symbole + " vs " + $( this ).attr( "data-symbol")
        if $( this ).attr( "data-symbol") is activer_copier_symbole
          html = ""
          fraction1 = fracString_to_frac $( this ).attr( "data-value") 
          activer_copier_contenu.each ->
            fraction2 = fracString_to_frac $( this ).attr("data-value")
            value = fraction1.multiplier fraction2
            type = $( this ).attr("data-type")       
            if symbol is "rationnel"
              (new Monome()).insert id, side, value
            else
              (new Monome()).insert id, side, value, "#{symbol}"
          $( this ).hide "easeInElastic", () -> $( this ).remove()           
    id = get_focused_id()    
    check_substitute(side, id) for side in ["gauche", "droite"]

       
