  
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
  
  
  # Le petit panel tactile    
  for char in  liste_des_variables.concat liste_des_operateurs.concat ["/"].concat liste_des_signes
    $("#equation_panel").append("<button id='var_#{char}' class='panel_touch'>#{char}</button>")
  #$("#equation_panel").append("<br>")
  for char in liste_des_chiffres
    $("#equation_panel").append("<button id='var_#{char}' class='panel_touch'>#{char}</button>")
  $( "button" ).button()
  
  # effacer l'invite _ commande
  $("#effacer_equation_string").on "click", ->  $( "#equation_string" ).val( "" )
  
  # selectionner tous les termes d'une equation
  $( "body" ).on "click", ".selectAllButton", (event) ->
  $("#equation_#{id}.focus ul > .monome").addClass( "selected" ) if id = get_focused_id()
  $( "body" ).on "click", ".simplifier_les_monomes", () -> if id = get_focused_id() then $( "#equation_#{id} > ul > li.selected" ).each -> monome_irreductible $(this)
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
   
   <br>
                        <div id="box" class="jxgbox" style="visibility : hidden; width:300px; height:300px;"></div>
                        <div id="equation_panel">
                              <button id="generer_equation" title="générer une équation du premier degré">Générer</button>
                              <button id="inserer_equation" title="Ajouter au système d'équation">Inserer</button>     
                              
                              
                              
                              <button class="selectAllButton" title="Sélectionner tous les termes de cette équation">Sélectionner tout</button>
                              
                              <button class="sommationMonome" title="Effectuer la somme des termes sélectionnés dans chaque membre">&Sigma;</button>
                              <button class="simplifier_les_monomes" title="rendre les fractions des termes sélectionnés irréductibles">&frac12;</button>   
                                             
                              <input id="equation_string" type="text" size="70" value="">
                              <button id="effacer_equation_string" title="effacer">Effacer</button>
                              <button id="var_&leftarrow;" class='panel_touch'>&leftarrow;</button>   

                              <button class="ajouter" title="Ajouter un terme à chaque membre de cette équation">
                                 <span class="equation_string_sample">+</span>
                              </button>
                              <button class="retrancher" title="Retrancher un terme à chaque membre de cette équation">
                                  <span class="equation_string_sample">-</span>
                              </button>
                              <button class="multiplier_distribuer" title="Multiplier par un terme chaque membre de cette équation">
                                  <span class="equation_string_sample">*.*.</span>
                              </button>
                              <button class="multiplier_factoriser" title="Multiplier par un terme chaque membre de cette équation">
                                  <span class="equation_string_sample">*(..)</span>
                              </button>        
                              <button class="diviser"  title="Diviser par un terme chaque membre de cette équation">
                                <span class="equation_string_sample">1/</span>
                              </button>
                             
                               
                      </div>  

<li><a id="toggle-box" href="#"  class="ui-btn ui-btn-inline ui-icon-plus ui-corner-all ui-btn-icon-notext" >on/off graph</a></li>
.jxgbox {
    position : fixed !important;
    top : 33%;
    left : 5%;
    display : inline-block;

    overflow: hidden;
    background-color: #ffffff;
    border-style: solid;
    border-width: 1px;
    border-color: #356AA0;
    border-radius: 10px;
    -webkit-border-radius: 10px;
    -ms-touch-action: none;
}

.JXGtext {
    /* May produce artefacts in IE. Solution: setting a color explicitly. */
    background-color: transparent;
    font-family: Arial, Helvetica, Geneva, sans-serif;
    padding: 0;
    margin: 0;
}

.JXGinfobox {
    border-style: none;
    border-width: 1px;
    border-color: black;
}

.JXGimage {
    opacity: 0;
}

.JXGimageHighlight {
    opacity: 0;
}


