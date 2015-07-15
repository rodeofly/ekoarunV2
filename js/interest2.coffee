  
  $( "body" ).on "click ", "#ul.operateur.multiplication", (event) ->
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

  $( "body" ).on "click", "#ul.operateur.addition", (event) ->
    op = get_operateur( $( this ) )
    if $( "#{op.id} > ul.operateur" ).length is 0 #il n'y a que des monomes
      coeffs = {}
      coeffs["1"] = new Fraction 0, 1
      $( "#{op.id} > li.monome" ).each -> 
        m = get_monome( $( this ) )        
        coeffs[  m.symbol   ] = if coeffs[m.symbol]? then m.fraction.ajouter coeffs[m.symbol] else m.fraction
        $( m.id ).remove()
      for symbol, fraction of coeffs
        m = new Monome()
        m.fraction = fraction
        m.symbol = symbol
        m.insert( op.id )
    
   
