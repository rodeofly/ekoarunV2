// Generated by CoffeeScript 1.4.0
(function() {
  var Fraction, Monome, Operateur, ajouter_membre, fracString_to_frac, generate_equation, get_focused_id, get_monome, get_operateur, megateuf, monomeString_to_array, monome_irreductible, multiplier_distribuer_membre, multiplier_factoriser_membre, operation_sur_equation, stringIdToString;

  Fraction = (function() {

    function Fraction(numerateur, denominateur) {
      this.numerateur = numerateur;
      this.denominateur = denominateur;
    }

    Fraction.prototype.irreductible = function() {
      var a, b, _ref, _ref1, _ref2, _ref3;
      _ref = [this.numerateur, this.denominateur], a = _ref[0], b = _ref[1];
      while (b !== 0) {
        _ref1 = [b, a % b], a = _ref1[0], b = _ref1[1];
      }
      _ref2 = [this.numerateur / a, this.denominateur / a], this.numerateur = _ref2[0], this.denominateur = _ref2[1];
      if (this.denominateur < 0) {
        _ref3 = [-this.numerateur, -this.denominateur], this.numerateur = _ref3[0], this.denominateur = _ref3[1];
      }
      return this;
    };

    Fraction.prototype.inverse = function() {
      var _ref;
      if (this.numerateur !== 0) {
        _ref = [this.denominateur, this.numerateur], this.numerateur = _ref[0], this.denominateur = _ref[1];
        return this;
      }
    };

    Fraction.prototype.oppose = function() {
      this.numerateur = -this.numerateur;
      return this;
    };

    Fraction.prototype.toString = function() {
      return "" + this.numerateur + "/" + this.denominateur;
    };

    Fraction.prototype.toHtml = function() {
      var html;
      if (this.numerateur / this.denominateur === 1) {
        return html = "<span class='plus'>&plus;</span>";
      } else if (this.numerateur / this.denominateur === -1) {
        return html = "<span class='moins'>&minus;</span>";
      } else if (this.denominateur === 1) {
        if (this.numerateur < 0) {
          return html = "<span class='moins'>&minus;</span><span class='rationnel'>" + (Math.abs(this.numerateur)) + "</span>";
        } else {
          return html = "<span class='plus'>&plus;</span><span class='rationnel'>" + this.numerateur + "</span>";
        }
      } else {
        if (this.numerateur < 0) {
          return html = "<span class='moins'>&minus;</span><span class='fraction'><span class='top'>" + (Math.abs(this.numerateur)) + "</span><span class='bottom'>" + this.denominateur + "</span></span>";
        } else {
          return html = "<span class='plus'>&plus;</span><span class='fraction'><span class='top'>" + this.numerateur + "</span><span class='bottom'>" + this.denominateur + "</span></span>";
        }
      }
    };

    Fraction.prototype.ajouter = function(fraction) {
      var _ref, _ref1;
      if (this.nominateur !== fraction.denominateur) {
        _ref = [this.numerateur * fraction.denominateur + fraction.numerateur * this.denominateur, this.denominateur * fraction.denominateur], this.numerateur = _ref[0], this.denominateur = _ref[1];
      } else {
        _ref1 = [this.numerateur + fraction.numerateur, this.denominateur], this.numerateur = _ref1[0], this.denominateur = _ref1[1];
      }
      return this;
    };

    Fraction.prototype.multiplier = function(fraction) {
      var _ref;
      _ref = [this.numerateur * fraction.numerateur, this.denominateur * fraction.denominateur], this.numerateur = _ref[0], this.denominateur = _ref[1];
      return this;
    };

    return Fraction;

  })();

  fracString_to_frac = function(value) {
    var d, foo, n, _ref;
    foo = value.split("/");
    switch (foo.length) {
      case 2:
        _ref = [parseInt(foo[0]), parseInt(foo[1])], n = _ref[0], d = _ref[1];
        if ((n != null) && (d != null)) {
          return foo = new Fraction(n, d);
        } else {
          return alert("Erreur : fracString_to_frac, n is " + n + " and d is " + d + " !");
        }
        break;
      case 1:
        n = parseInt(foo[0]);
        if (n != null) {
          return foo = new Fraction(n, 1);
        } else {
          return alert("Erreur : fracString_to_frac, n is " + n + " !");
        }
        break;
      default:
        return alert("Erreur : fracString_to_frac, value is " + value + " !");
    }
  };

  Monome = (function() {

    function Monome(fraction, symbol, power) {
      var _ref, _ref1, _ref2;
      this.fraction = fraction;
      this.symbol = symbol;
      this.power = power;
      this.id = "#" + (unique_id++);
      if ((_ref = this.fraction) == null) {
        this.fraction = new Fraction(1, 1);
      }
      if ((_ref1 = this.symbol) == null) {
        this.symbol = "1";
      }
      if ((_ref2 = this.power) == null) {
        this.power = 1;
      }
    }

    Monome.prototype.isZero = function() {
      return this.fraction.numerateur === 0;
    };

    Monome.prototype.isOne = function() {
      return (this.fraction.numerateur / this.fraction.denominateur === 1) && (this.symbol === "1");
    };

    Monome.prototype.clone = function() {
      var m;
      m = new Monome();
      m.id = "#" + (unique_id++);
      m.parent_id = this.parent_id;
      m.fraction = this.fraction;
      m.symbol = this.symbol;
      m.power = this.power;
      return m;
    };

    Monome.prototype.randomize = function(symbol, power) {
      var coeff, max, min;
      this.symbol = symbol;
      this.power = power;
      min = -10;
      max = 10;
      coeff = Math.floor(Math.random() * (max - min + 1)) + min;
      this.fraction = new Fraction(coeff, 1);
      return this;
    };

    Monome.prototype.update = function() {
      var o;
      this.parent_id = "#" + ($(this.id).parent().attr("id"));
      if ((!generate) && ($(this.id).siblings().length === 0) && (!$(this.parent_id).parent().hasClass("equation"))) {
        $(this.parent_id).contents().unwrap();
        this.parent_id = "#" + ($(this.id).parent().attr("id"));
      }
      $(this.id).attr("data-fraction", this.fraction.irreductible().toString());
      if (this.isZero()) {
        $(this.id).attr("data-symbol", this.symbol = "1");
      } else {
        $(this.id).attr("data-symbol", this.symbol);
      }
      if (this.symbol === "1") {
        $(this.id).attr("data-power", this.power = 1);
      } else {
        $(this.id).attr("data-power", this.power);
      }
      o = get_operateur($(this.parent_id));
      if (!generate) {
        switch (o.type) {
          case "addition":
            if ((this.isZero()) && ($(this.id).siblings().length !== 0)) {
              $(this.id).remove();
            } else {
              $(this.id).html(this.html_content());
            }
            break;
          case "multiplication":
            if ((this.isOne()) && ($(this.id).siblings().length !== 0)) {
              $(this.id).remove();
            } else {
              if (this.isZero()) {
                $(this.id).siblings().remove();
              }
              $(this.id).html(this.html_content());
            }
        }
      } else {
        $(this.id).html(this.html_content());
      }
      $("" + o.id + ".addition > " + this.id + ".monome").droppable({
        accept: "" + o.id + ".addition > li.monome",
        hoverClass: "state-hover",
        activeClass: "li-state-active",
        drop: function(event, ui) {
          var draggable, droppable;
          event.stopImmediatePropagation();
          event.stopPropagation();
          console.log("drop l'addition !");
          draggable = get_monome(ui.draggable);
          droppable = get_monome($(this));
          if (((draggable.symbol === droppable.symbol) && (draggable.power === droppable.power)) || (draggable.isZero())) {
            droppable.fraction.ajouter(draggable.fraction);
            droppable.update();
            draggable.remove();
          } else {
            if (draggable.power !== droppable.power) {
              alert("attention, ce n'est pas la meme puissance !");
            } else {
              alert("On ne peut pas tout mélanger !");
            }
          }
          return megateuf();
        }
      });
      return $("" + o.id + ".multiplication > " + this.id + ".monome").droppable({
        accept: "" + o.id + ".multiplication > li.monome",
        hoverClass: "state-hover",
        activeClass: "li-state-active",
        drop: function(event, ui) {
          var draggable, droppable, _ref, _ref1;
          event.stopImmediatePropagation();
          event.stopPropagation();
          console.log("drop la multiplication !");
          draggable = get_monome(ui.draggable);
          droppable = get_monome($(this));
          droppable.fraction.multiplier(draggable.fraction);
          if (!draggable.isZero()) {
            draggable.fraction = new Fraction(1, 1);
          }
          if (draggable.symbol === droppable.symbol) {
            droppable.power += draggable.power;
            draggable.remove();
          } else if (draggable.symbol === "1") {
            draggable.remove();
          } else if (droppable.symbol === "1") {
            droppable.symbol = draggable.symbol;
            droppable.power = draggable.power;
            draggable.remove();
          } else {
            _ref = [droppable.symbol, draggable.symbol], draggable.symbol = _ref[0], droppable.symbol = _ref[1];
            _ref1 = [droppable.power, draggable.power], draggable.power = _ref1[0], droppable.power = _ref1[1];
            draggable.update();
          }
          droppable.update();
          return megateuf();
        }
      });
    };

    Monome.prototype.irreductible = function() {
      this.fraction.irreductible();
      return this.update();
    };

    Monome.prototype.remove = function() {
      return $(this.id).remove();
    };

    Monome.prototype.html_content = function() {
      var html, power_div, symbol_div;
      if ((this.symbol !== "1") || (Math.abs(this.fraction.numerateur / this.fraction.denominateur) === 1)) {
        symbol_div = "<span class='symbol'>" + this.symbol + "</span>";
      } else {
        symbol_div = "";
      }
      power_div = this.power === 1 ? "" : "<sup class='power'>" + this.power + "</sup>";
      return html = "" + (this.fraction.toHtml()) + symbol_div + power_div;
    };

    Monome.prototype.insert = function(parent_id) {
      this.parent_id = parent_id;
      $(this.parent_id).append("<li id='" + this.id.slice(1) + "' class='monome item' data-fraction='" + this.fraction + "' data-symbol='" + this.symbol + "'  data-power='" + this.power + "'></li>");
      return this.update();
    };

    Monome.prototype.insert_from_string = function(equation_id, monomeString) {
      var m, _ref, _ref1;
      this.equation_id = equation_id;
      m = monomeString.split(".");
      this.fraction = fracString_to_frac(m[0]);
      alert(this.fraction);
      if (m.length > 1) {
        m = m[1].split("^");
        _ref = [m[0], m[1]], this.symbol = _ref[0], this.power = _ref[1];
      } else {
        _ref1 = [1, 1], this.symbol = _ref1[0], this.power = _ref1[1];
      }
      return (new Monome()).insert(this.equation_id);
    };

    Monome.prototype.ajouter = function(monome) {
      if (this.symbol === monome.symbol) {
        this.fraction.ajouter(monome.fraction);
      } else {
        alert("On ne mélange pas symboles & chiffres !");
      }
      return this;
    };

    Monome.prototype.toString = function() {
      return "" + (this.fraction.toString()) + "." + this.symbol + "^" + this.power;
    };

    Monome.prototype.toArray = function() {
      return monomeString_to_array(this.toString());
    };

    Monome.prototype.toHtml = function() {
      var html;
      return html = "<li id='" + this.id.slice(1) + "' class='monome item' data-fraction='" + (this.fraction.toString()) + "' data-symbol='" + this.symbol + "' data-power='" + this.power + "'><span class='monome_html'>" + (this.html_content()) + "</span></li>";
    };

    return Monome;

  })();

  monome_irreductible = function($monome) {
    var m;
    return (m = get_monome($monome)).irreductible();
  };

  monomeString_to_array = function(s) {
    var foo, fracString, pattern_terme, power, symbol;
    if (debug) {
      console.log("monomeString_to_array(" + s + ")");
    }
    pattern_terme = /([\+\-]?\d+(?:\/\d+)*)[.+](\w+)\^(\d+)*/g;
    foo = s.match(pattern_terme);
    if ((foo != null) && foo[0] === s) {
      foo = regex.exec(pattern_terme);
      fracString = foo[1];
      symbol = foo[2];
      return power = foo[3];
    } else {
      return alert("Vous devriez effacer l'invite de commande et envisager quelquechose de mieux pondéré...ok !?");
    }
  };

  get_monome = function($monome) {
    var m;
    if ($monome.is("[data-fraction]") && $monome.is("[data-symbol]") && $monome.is("[data-power]")) {
      m = new Monome();
      m.id = "#" + ($monome.attr('id'));
      m.parent_id = "#" + ($(m.id).parent().attr('id'));
      m.fraction = fracString_to_frac($(m.id).attr("data-fraction"));
      m.symbol = $(m.id).attr("data-symbol");
      m.power = parseInt($(m.id).attr("data-power"));
      return m;
    } else {
      return alert("get_monome did not work !");
    }
  };

  Operateur = (function() {

    function Operateur(symbol, compacted) {
      var classe, _ref, _ref1;
      this.symbol = symbol;
      this.compacted = compacted;
      classe = {
        "*": "multiplication",
        "+": "addition"
      };
      this.id = "#" + (unique_id++);
      if ((_ref = this.symbol) == null) {
        this.symbol = "+";
      }
      this.type = classe[this.symbol];
      if ((_ref1 = this.compacted) == null) {
        this.compacted = false;
      }
    }

    Operateur.prototype.toHtml = function() {
      var html;
      return html = "<ul id='" + this.id.slice(1) + "' class='operateur " + this.type + " item' data-symbol='" + this.symbol + "' data-type='" + this.type + "' data-compacted='" + this.compacted + "'></ul>";
    };

    Operateur.prototype.clone = function() {
      var o;
      o = new Operateur();
      o.id = "#" + (unique_id++);
      o.parent_id = this.parent_id;
      o.type = this.type;
      o.symbol = this.symbol;
      o.compacted = this.compacted;
      return o;
    };

    Operateur.prototype.monomesString_insert = function(membre) {
      var monomeString, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = membre.length; _i < _len; _i++) {
        monomeString = membre[_i];
        _results.push((new Monome()).insert_from_string(this.id, monomeString));
      }
      return _results;
    };

    Operateur.prototype.toStringId = function() {
      var string, symbol;
      symbol = this.symbol;
      string = "";
      $(this.id).children().each(function() {
        var m;
        if ($(this).is("ul")) {
          m = get_operateur($(this));
          return string += "" + symbol + "[" + (m.toStringId()) + "]";
        } else {
          m = get_monome($(this));
          return string += "" + symbol + m.id;
        }
      });
      return string.slice(1);
    };

    return Operateur;

  })();

  stringIdToString = function(stringId) {
    return stringId.replace(/(\#\d+)/g, function(match, id, offset, string) {
      console.log(id);
      return get_monome($(id)).toString();
    });
  };

  get_operateur = function($operateur) {
    var o;
    if ($operateur.is("[data-symbol]") && $operateur.is("[data-type]") && $operateur.is("[data-compacted]")) {
      o = new Operateur();
      o.id = "#" + ($operateur.attr('id'));
      o.parent_id = "#" + ($(o.id).parent().attr('id'));
      o.type = $(o.id).attr("data-type");
      o.symbol = $(o.id).attr("data-symbol");
      o.compacted = $(o.id).attr("data-compacted");
      return o;
    } else {
      return alert("get_operateur did not work !");
    }
  };

  megateuf = function() {
    try {
      return $("li.monome").each(function() {
        return get_monome($(this)).update();
      });
    } catch (error) {

    } finally {
      $("ul.operateur").each(function() {
        var o;
        o = get_operateur($(this));
        if ((o.symbol === $(o.parent_id).attr("data-symbol")) || (($(o.id).siblings().length === 0) && (!$(o.parent_id).hasClass("equation")))) {
          $(o.id).contents().unwrap();
          return megateuf();
        }
      });
      $(".equation ul.operateur").each(function() {
        var o;
        o = get_operateur($(this));
        $("" + o.id + ".addition > ul.multiplication").droppable({
          accept: "" + o.id + ".addition > ul.multiplication",
          hoverClass: "state-hover",
          activeClass: "ul-state-active",
          drop: function(event, ui) {
            var draggable, droppable, m1, m2, match1, match2, str1, str2, _ref, _ref1;
            event.stopImmediatePropagation();
            event.stopPropagation();
            droppable = get_operateur($(this));
            draggable = get_operateur(ui.draggable);
            str1 = stringIdToString(droppable.toStringId());
            str2 = stringIdToString(draggable.toStringId());
            _ref = [/([-+]?\d+(?:\/\d+)?)[\.+](.*)/g.exec(str1), /([-+]?\d+(?:\/\d+)?)[\.+](.*)/g.exec(str2)], match1 = _ref[0], match2 = _ref[1];
            if ((match1 != null) && (match2 != null) && (match1.length === 3) && (match2.length === 3) && (match1[2] === match2[2])) {
              console.log("match factor !");
              _ref1 = [get_monome($(droppable.id).children("li:first")), get_monome($(draggable.id).children("li:first"))], m1 = _ref1[0], m2 = _ref1[1];
              m1.fraction.ajouter(m2.fraction);
              $(draggable.id).remove();
              return megateuf();
            } else {
              return alert("les facteurs ne coincident pas !");
            }
          }
        });
        $("" + o.id + ".multiplication > ul.addition").droppable({
          accept: "" + o.id + ".multiplication > li.monome, " + o.id + ".multiplication > ul.addition",
          hoverClass: "state-hover",
          activeClass: "ul-state-active",
          drop: function(event, ui) {
            var draggable, droppable, generate;
            generate = true;
            droppable = get_operateur($(this));
            if (ui.draggable.is("ul.addition")) {
              draggable = get_operateur(ui.draggable);
              $("" + droppable.id + " > .item").each(function() {
                var clone, factor, item, o1, _i, _len, _ref;
                factor = $(this).is("ul") ? get_operateur($(this)) : get_monome($(this));
                o1 = new Operateur("*");
                $(factor.id).after(o1.toHtml());
                console.log(factor.symbol);
                _ref = [factor, draggable];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  item = _ref[_i];
                  clone = item.clone();
                  $(o1.id).append(clone.toHtml());
                  $(clone.id).html($(item.id).html());
                  $(clone.id).find('[id]').each(function() {
                    return $(this).attr("id", "" + (unique_id++));
                  });
                }
                return $(factor.id).remove();
              });
              $(draggable.id).remove();
            } else {
              draggable = get_monome(ui.draggable);
              $("" + droppable.id + " > .item").each(function() {
                var clone, o1;
                generate = true;
                o1 = new Operateur("*");
                $(this).after(o1.toHtml());
                clone = draggable.clone();
                $(o1.id).append($(this)).append(clone.toHtml());
                $(clone.id).html($(draggable.id).html());
                return $(clone.id).find('[id]').each(function() {
                  return $(this).attr("id", "" + (unique_id++));
                });
              });
              $(draggable.id).remove();
            }
            generate = false;
            return megateuf();
          }
        });
        return $(".equation > " + o.id).droppable({
          accept: function(draggable) {
            return (draggable.parent().parent().attr("id") === $(o.parent_id).attr("id")) && (draggable.parent().attr("id") !== $(o.id).attr("id")) && (draggable.parent().hasClass("addition"));
          },
          hoverClass: "state-hover",
          activeClass: "ul-state-active",
          drop: function(event, ui) {
            var generate, m, w;
            o = get_operateur($(this));
            switch (o.type) {
              case "addition":
                generate = true;
                o = new Operateur("*");
                $(this).append(o.toHtml());
                m = new Monome();
                m.fraction.oppose();
                m.insert(o.id);
                $(o.id).append(ui.draggable);
                generate = false;
                megateuf();
                break;
              case "multiplication":
                generate = true;
                w = new Operateur("+");
                $(this).wrap(w.toHtml());
                o = new Operateur("*");
                $(w.id).append(o.toHtml());
                m = new Monome();
                m.fraction.oppose();
                m.insert(o.id);
                $(o.id).append(ui.draggable);
                generate = false;
            }
            return megateuf();
          }
        });
      });
      $("ul.operateur, li.monome").draggable({
        revert: true
      });
    }
  };

  generate_equation = function() {
    var alphabet, create_equation_membre, generate, html, id, signe;
    generate = true;
    id = unique_id++;
    signe = signes[Math.floor(Math.random() * signes.length)];
    html = "<div id='equation_" + id + "' class='equation' >\n    <a href='#' id='deleteButton_" + id + "' class=\"deleteButton ui-btn ui-corner-all ui-icon-delete ui-btn-icon-notext ui-btn-inline ui-btn-left\">title=Supprimer cette équation</a>\n    <span id='signe_" + id + "' class='signe'>" + signe + "</span>\n</div>";
    $("#equations_div").append(html);
    alphabet = ['1', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'].slice(0, +parseInt($("#slider-variable").val()) + 1 || 9e9);
    create_equation_membre = function(type, place) {
      var i, j, k, m, op1, op2, op3, other, _i, _ref, _results;
      other = {
        "+": "*",
        "*": "+"
      };
      op1 = new Operateur(type);
      if (place === "before") {
        $("#signe_" + id).before(op1.toHtml());
      } else {
        $("#signe_" + id).after(op1.toHtml());
      }
      console.log($("#operateur_type :radio:checked").val(), type, op1);
      _results = [];
      for (i = _i = 1, _ref = parseInt($("#slider-facteur").val()); 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        op2 = new Operateur(type);
        $(op1.id).append(op2.toHtml());
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (j = _j = 1, _ref1 = parseInt($("#rangeslider-minimax-max").val()); 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 1 <= _ref1 ? ++_j : --_j) {
            op3 = new Operateur(other[type]);
            $(op2.id).append(op3.toHtml());
            _results1.push((function() {
              var _k, _len, _results2;
              _results2 = [];
              for (_k = 0, _len = alphabet.length; _k < _len; _k++) {
                k = alphabet[_k];
                m = new Monome();
                _results2.push(m.randomize(alphabet.shuffle()[0], 1).insert(op3.id));
              }
              return _results2;
            })());
          }
          return _results1;
        })());
      }
      return _results;
    };
    create_equation_membre($("#operateur_type :radio:checked").val(), "before");
    create_equation_membre($("#operateur_type :radio:checked").val(), "after");
    megateuf();
    return generate = false;
  };

  ajouter_membre = function(string) {
    var id;
    id = get_focused_id();
    if (id) {
      return $("#equation_" + id + " > ul.operateur").each(function() {
        var op;
        op = new Operateur("+");
        $(this).append(op.toHtml());
        return op.monomesString_insert(string);
      });
    }
  };

  multiplier_distribuer_membre = function(facteur) {
    var id;
    id = get_focused_id();
    if (id && facteur.denominateur) {
      return $("#equation_" + id + " > ul.operateur > li.monome").each(function() {
        var m;
        m = get_monome($(this));
        m.fraction.multiplier(facteur);
        return m.update();
      });
    }
  };

  multiplier_factoriser_membre = function(string) {
    var id;
    id = get_focused_id();
    if (id) {
      return $("#equation_" + id + " > .operateur").each(function() {
        var op;
        op = new Operateur("*");
        $(this).wrap(op.toHtml());
        return op.monomesString_insert(string);
      });
    }
  };

  get_focused_id = function() {
    var id;
    return id = $(".focus").attr("id") ? $(".focus").attr("id").split("_")[1] : alert("Selectionner une équation !");
  };

  operation_sur_equation = function(mode, id) {
    var array;
    id = get_focused_id();
    array = monomeString_to_array($("#equation_string").val());
    if ((id != null) && (array != null)) {
      switch (mode) {
        case "diviser":
          return multiplier_distribuer_membre(fracString_to_frac(array[0], array[1]));
        case "multiplier_factoriser":
          return multiplier_factoriser_membre($("#equation_string").val().split("+"));
        case "multiplier_distribuer":
          return multiplier_distribuer_membre(fracString_to_frac(array[0], array[1]));
        case "retrancher":
          return ajouter_membre((fracString_to_frac(array[0])).oppose(), array[1]);
        case "ajouter":
          return ajouter_membre($("#equation_string").val().split("+"));
      }
    } else {
      return alert("Poids surement mal formé !");
    }
  };

}).call(this);
