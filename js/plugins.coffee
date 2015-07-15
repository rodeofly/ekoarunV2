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

###################################################################################################
###################################################################################################
################################################################################################### 
# Monomes
    
class Monome
  constructor: (@fraction, @symbol, @power) ->
    @id = "##{unique_id++}"
    @fraction ?= new Fraction(1,1)
    @symbol ?= "1"
    @power ?= 1
  
  isZero : () -> @fraction.numerateur is 0 
  
  isOne : () -> ( (@fraction.numerateur/@fraction.denominateur is 1) and ( @symbol is "1" ) )  
  
  clone : () -> 
    m = new Monome()
    m.id = "##{unique_id++}"
    m.parent_id = @parent_id
    m.fraction = @fraction
    m.symbol = @symbol
    m.power = @power
    return m
     
  randomize: (@symbol, @power) ->
    min = -10
    max = 10
    coeff = Math.floor(Math.random() * (max-min+1)) + min
    @fraction = new Fraction(coeff,1)
    return this

  update : () ->
    @parent_id = "##{$( @id ).parent().attr( "id" )}"
    if (( not generate ) and ( $( @id ).siblings().length is 0 ) and ( not $( @parent_id ).parent().hasClass( "equation" ) ) )
      $( @parent_id ).contents().unwrap()
      @parent_id = "##{$( @id ).parent().attr( "id" )}"
    
    $( @id ).attr "data-fraction", @fraction.irreductible().toString()
    if this.isZero()    then $( @id ).attr( "data-symbol", @symbol = "1" ) else $( @id ).attr( "data-symbol", @symbol ) 
    if (@symbol is "1") then $( @id ).attr "data-power", @power = 1        else $( @id ).attr "data-power", @power  
    
    o = get_operateur $( @parent_id )
    if not generate
      switch o.type # si l'operateur est une...
        when "addition"
          if ( ( this.isZero() ) and ( $( @id ).siblings().length isnt 0 ) )# et si ce monome c'est zero
            $( @id ).remove() 
          else 
            $( @id ).html( this.html_content() ) # mais que c'est le dernier on le garde...
        when "multiplication"
          if ( ( this.isOne()  ) and ( $( @id ).siblings().length isnt 0 ) )# et si ce monome c'est zero
            $( @id ).remove() 
          else
            $( @id ).siblings().remove() if this.isZero() # si c'est un zero il absorbe les voisins
            $( @id ).html( this.html_content() )
    else
      $( @id ).html( this.html_content() )
    
    $( "#{o.id}.addition > #{@id}.monome" ).droppable accept : "#{o.id}.addition > li.monome", hoverClass : "state-hover", activeClass: "li-state-active", drop: (event, ui) ->   
      event.stopImmediatePropagation()
      event.stopPropagation()
      console.log "drop l'addition !"
      draggable = get_monome( ui.draggable ) 
      droppable = get_monome( $( this ) )  
      if ( ((draggable.symbol is droppable.symbol) and (draggable.power is droppable.power)) or ( draggable.isZero() ) )
        droppable.fraction.ajouter draggable.fraction  
        droppable.update()
        draggable.remove()
      else
        if (draggable.power isnt droppable.power)
          alert "attention, ce n'est pas la meme puissance !"
        else
          alert "On ne peut pas tout mélanger !"
      megateuf()
          
    $( "#{o.id}.multiplication > #{@id}.monome" ).droppable accept : "#{o.id}.multiplication > li.monome", hoverClass : "state-hover", activeClass: "li-state-active", drop: (event, ui) ->      
      event.stopImmediatePropagation()
      event.stopPropagation()
      console.log "drop la multiplication !"
      draggable = get_monome( ui.draggable )
      droppable = get_monome( $( this ) )
      droppable.fraction.multiplier draggable.fraction
      draggable.fraction = new Fraction(1, 1) if ( not draggable.isZero() ) 
      if (draggable.symbol is droppable.symbol)
        droppable.power += draggable.power
        draggable.remove()
      else if draggable.symbol is "1"
        draggable.remove() 
      else if droppable.symbol is "1"
        droppable.symbol = draggable.symbol
        droppable.power = draggable.power
        draggable.remove() 
      else
        [draggable.symbol, droppable.symbol ] = [  droppable.symbol, draggable.symbol ]
        [draggable.power, droppable.power ] = [  droppable.power, draggable.power ]
        draggable.update()
      droppable.update() 
      megateuf()
          
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
    
  insert: ( @parent_id ) ->
    $( @parent_id ).append "<li id='#{@id[1..]}' class='monome item' data-fraction='#{@fraction}' data-symbol='#{@symbol}'  data-power='#{@power}'></li>"
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

monome_irreductible = ($monome) -> (m = get_monome($monome)).irreductible()
  
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
###################################################################################################
###################################################################################################
###################################################################################################
#Operateur
     
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
    
stringIdToString = (stringId) ->
  stringId.replace /(\#\d+)/g, (match, id, offset, string) ->
      console.log id
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
###################################################################################################
###################################################################################################
###################################################################################################
#Équation   
  
megateuf = () ->
  try
    $( "li.monome" ).each -> get_monome( $( this ) ).update()
  catch error
  finally
  
    $( "ul.operateur" ).each -> 
      o = get_operateur( $(this) )
      if ( ( o.symbol is $( o.parent_id ).attr("data-symbol") ) or ( ( $(o.id).siblings().length is 0 ) and ( not $( o.parent_id ).hasClass("equation") ) ) ) #(+ (+) ) | (+ (+) )
        $( o.id ).contents().unwrap()
        megateuf()

    $( ".equation ul.operateur" ).each ->   
      o = get_operateur( $(this) )
      #Addition de multiplication
      $( "#{o.id}.addition > ul.multiplication" ).droppable accept : "#{o.id}.addition > ul.multiplication", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->  
        event.stopImmediatePropagation()
        event.stopPropagation()    
        droppable = get_operateur( $( this ) )

        draggable = get_operateur( ui.draggable )
        str1 = stringIdToString( droppable.toStringId() ) 
        str2 = stringIdToString( draggable.toStringId() )    
        [match1, match2 ] = [/([-+]?\d+(?:\/\d+)?)[\.+](.*)/g.exec( str1 ), /([-+]?\d+(?:\/\d+)?)[\.+](.*)/g.exec( str2 ) ]
        if ( match1? and match2? and (match1.length is 3) and (match2.length is 3 ) and (match1[2] is match2[2]) )
          console.log "match factor !"
          [ m1, m2 ] = [ get_monome( $( droppable.id ).children("li:first") ), get_monome( $( draggable.id ).children("li:first") ) ]
          m1.fraction.ajouter m2.fraction
          $( draggable.id ).remove()
          megateuf()
        else alert "les facteurs ne coincident pas !" 
      
      #distributivité de la multiplication sur l'addition
      $( "#{o.id}.multiplication > ul.addition" ).droppable accept : "#{o.id}.multiplication > li.monome, #{o.id}.multiplication > ul.addition", hoverClass : "state-hover", activeClass: "ul-state-active", drop: (event, ui) ->
        generate = true        
        droppable = get_operateur( $( this ) )
        if ui.draggable.is "ul.addition"  # Distribution d'une multiplication sur une addition
          draggable = get_operateur( ui.draggable )

          $( "#{droppable.id} > .item").each () ->  
                     
            factor = if $(this).is("ul") then get_operateur($(this)) else get_monome($(this))
            o1 = new Operateur( "*" )
            $( factor.id ).after( o1.toHtml() )
            console.log factor.symbol
            
            for item in [factor, draggable] 
              clone = item.clone()
              $( o1.id ).append clone.toHtml()            
              $( clone.id ).html( $( item.id ).html() )
              $( clone.id ).find('[id]').each -> $( this ).attr("id", "#{unique_id++}" )
            $( factor.id ).remove()

          $( draggable.id ).remove()
        else
          draggable = get_monome ui.draggable
          $( "#{droppable.id} > .item").each () ->
            generate = true
            o1 = new Operateur( "*" )
            $( this ).after( o1.toHtml() )
            clone = draggable.clone()
            $( o1.id ).append( $( this ) ).append( clone.toHtml() )
            $( clone.id ).html( $( draggable.id ).html() )
            $( clone.id ).find('[id]').each -> $( this ).attr("id", "#{unique_id++}" )
          $( draggable.id ).remove()   
        generate = false      
        megateuf()


      $( ".equation > #{o.id}" ).droppable 
        accept : (draggable) -> 
         ( ( draggable.parent().parent().attr("id") is $( o.parent_id ).attr("id") ) and ( draggable.parent().attr("id") isnt $( o.id ).attr("id") ) and ( draggable.parent().hasClass("addition") ) )
        hoverClass : "state-hover"
        activeClass: "ul-state-active"
        drop: (event, ui) ->
          o = get_operateur( $(this) )
          switch o.type
            when "addition"
              generate = true
              o = new Operateur( "*" )
              $( this ).append( o.toHtml() )
              m = new Monome()
              m.fraction.oppose()
              m.insert o.id
              $( o.id ).append ui.draggable
              generate = false
              megateuf()
            when "multiplication"      
              generate = true
              w = new Operateur( "+" )
              $( this ).wrap w.toHtml() 
              o = new Operateur( "*" )
              $( w.id ).append( o.toHtml() )
              m = new Monome()
              m.fraction.oppose()
              m.insert o.id
              $( o.id ).append ui.draggable
              generate = false
          megateuf()
            
    
    $( "ul.operateur, li.monome" ).draggable revert : true
   
generate_equation = () ->
  generate = true
  id = unique_id++
  signe = signes[Math.floor Math.random() * signes.length]
  html =
  """
  <div id='equation_#{id}' class='equation' >
      <a href='#' id='deleteButton_#{id}' class="deleteButton ui-btn ui-corner-all ui-icon-delete ui-btn-icon-notext ui-btn-inline ui-btn-left">title=Supprimer cette équation</a>
      <span id='signe_#{id}' class='signe'>#{signe}</span>
  </div>
  """
  $( "#equations_div" ).append html
  #$("#equations_div" ).sortable()
  alphabet = (['1', 'a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'][0..parseInt $( "#slider-variable" ).val()])
  
  create_equation_membre = ( type, place ) ->
    other = {"+" : "*", "*" : "+"}  
    op1 = new Operateur( type )
    if place is "before" then  $( "#signe_#{id}" ).before(op1.toHtml()) else $( "#signe_#{id}" ).after(op1.toHtml())
    console.log $("#operateur_type :radio:checked").val(), type, op1
    for i in [1..parseInt $( "#slider-facteur" ).val()]
      op2 = (new Operateur type )
      $( op1.id ).append( op2.toHtml() )
      for j in [1..parseInt $( "#rangeslider-minimax-max" ).val()]
        op3 = new Operateur( other[type] )
        $( op2.id ).append( op3.toHtml() )
        for k in alphabet
          m = new Monome()
          m.randomize( alphabet.shuffle()[0] ,1).insert( op3.id )
          
  create_equation_membre( $("#operateur_type :radio:checked").val(), "before" ) 
  create_equation_membre( $("#operateur_type :radio:checked").val(), "after" )
  megateuf()
  generate = false

ajouter_membre = (string) ->
  id = get_focused_id()
  if (id )
    $( "#equation_#{id} > ul.operateur" ).each ->  
      op = new Operateur( "+")
      $(this).append( op.toHtml() )
      op.monomesString_insert( string )

multiplier_distribuer_membre = (facteur) ->
  id = get_focused_id()
  if (id and facteur.denominateur)
    $( "#equation_#{id} > ul.operateur > li.monome").each ->
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



# ---
# generated by js2coffee 2.0.4
