var vis = {
    id: 'flamegraph',
    label: 'Flamegraph',
    options: {
        color: {
            type: 'string',
            label: 'Custom Color',
            display: 'color',
        },
        diameter: {
            type: "string",
            label: "Diameter",
            default: '100%',
            placeholder: "100%"
        },
        stepwise_max_scale: {
            type: "number",
            label: "Stepwise Max Scale",
            placeholder: 4
        },
        top_label: {
            type: "string",
            label: "Title",
            placeholder: "My awesome chart"
        }
    },

    // Set up the initial state of the visualization
    create: function(element, config) {
        var css = '<style> .d3-flame-graph rect{stroke:#EEE;fill-opacity:.8}.d3-flame-graph rect:hover{stroke:#474747;stroke-width:.5;cursor:pointer}.d3-flame-graph-label{pointer-events:none;white-space:nowrap;text-overflow:ellipsis;overflow:hidden;font-size:12px;font-family:Verdana;margin-left:4px;margin-right:4px;line-height:1.5;padding:0;font-weight:400;color:#000;text-align:left}.d3-flame-graph .fade{opacity:.6!important}.d3-flame-graph .title{font-size:20px;font-family:Verdana}.d3-flame-graph-tip{line-height:1;font-family:Verdana;font-size:12px;padding:12px;background:rgba(0,0,0,.8);color:#fff;border-radius:2px;pointer-events:none}.d3-flame-graph-tip:after{box-sizing:border-box;display:inline;font-size:10px;width:100%;line-height:1;color:rgba(0,0,0,.8);position:absolute;pointer-events:none}.d3-flame-graph-tip.n:after{content:"\25BC";margin:-1px 0 0;top:100%;left:0;text-align:center}.d3-flame-graph-tip.e:after{content:"\25C0";margin:-4px 0 0;top:50%;left:-8px}.d3-flame-graph-tip.s:after{content:"\25B2";margin:0 0 1px;top:-8px;left:0;text-align:center}.d3-flame-graph-tip.w:after{content:"\25B6";margin:-4px 0 0 -1px;top:50%;left:100%} </style> ';
        element.innerHTML=css;
        container = element.appendChild(document.createElement("div"));
        this.container=container
        container.setAttribute("id","my-flamegraph");
        container.classList.add("d3-flame-graph");
    },

    // Render in response to the data or settings changing
    update: function(data, element, config, queryResponse) {
        this.container.innerHTML='' // clear container of previous vis so width & height is correct

        // requires no pivots, 3 dimensions, and 1 measure
        if (!handleErrors(this, queryResponse, { 
          min_pivots: 0, max_pivots: 0, 
          min_dimensions: 3, max_dimensions: 3, 
          min_measures: 1, max_measures: 1})) {
          return;
        } 
  
        var dim_1_parent_step = queryResponse.fields.dimensions[0].name, dim_2_step = queryResponse.fields.dimensions[1].name, dim_3_name = queryResponse.fields.dimensions[2].name;
        var measure = queryResponse.fields.measures[0].name;
        
        //rename keys
        rows = Object.keys(data).length;
        for (i=0; i<rows; i++) {
            data[i]["name"] = data[i][dim_2_step].value + ' ' + data[i][dim_3_name].value
            delete data[i][dim_3_name]
            data[i]["value"] = data[i][measure].value
            // delete data[i][measure]
            data[i]["children"] = []
        }

        // sort rows ascending by parent step
        data.sort(function(a, b) {
            return parseInt(a[dim_1_parent_step].value) - parseInt(b[dim_1_parent_step].value);
        });

        //nest children steps inside parent steps for chart
        while (rows > 1) {
            last_element = data[rows-1];
            last_element_parent = last_element[dim_1_parent_step].value;
            // console.log('last element is: ' + last_element['name']);
            // console.log('last element parent is: ' + last_element_parent);
            for (i=0; i<rows; i++) {
                if (data[i][dim_2_step].value == last_element_parent) {
                    // console.log('parent step found, pushing ' + last_element['name'] + ' to ' + data[i]['name']);
                    data[i]["children"].push(last_element);
                    if (data[i][measure].value!=last_element[measure].value) {
                        data[i]["value"]+=last_element["value"]
                    } else {
                      data[i]["value"]=last_element["value"]
                    }
                    // console.log('deleting ' + data[rows-1]['name']);
                    delete data[rows-1];
                    break;
                }
            }
            if (data[rows-1] == last_element) {
              vis.addError({
                title: "Data is not nestable",
                message: "Data must be in nested hierarchy structure.\
                          Ensure the 1st dimension is the parent id, 2nd dimension is the child id, and 3rd dimension is the descriptor."
              });
              break;
            }
            rows = Object.keys(data).length; 
        }

        data = data[0] 
        console.log(data);

        //scale children to minimum values
        var scaler = config.stepwise_max_scale;
        if (Number.isInteger(scaler)) {
          stepwise_scale(data, scaler);
        }

        // set chart diameter & max width
        var ratio = parseFloat(config.diameter) / 100.0;
        if (isNaN(ratio)) {
          var diameter = element.clientWidth;
        } else if (ratio > 10) {
          var diameter = element.clientWidth*10;
        } else {
          var diameter = Math.round(element.clientWidth*ratio);
        }

        // TODO reset color

        var flameGraph = d3.flamegraph()
            .width(diameter)
            .transitionDuration(1000)
            .title(config.top_label)
            .onClick(onClick);
            // .minFrameSize(5)
            // .height(element.clientHeight)
            // .cellHeight(18)
            // .transitionEase(d3.easeCubic)
            // .differential(false)
            // .elided(false)
            // .selfValue(false)

        // custom color formatting
        // console.log(config.color)
        if (config.color != null) {
          flameGraph.setColorMapper(function(d) {
              return config.color;
          });
        }

        // set the tooltip hover
        var tip = d3.tip()
          .direction("s")
          .offset([8, 0])
          .attr('class', 'd3-flame-graph-tip')
          .html(function(d) { return d.data.name + " (" + d.data.value.toLocaleString() + ")"; });
        flameGraph.tooltip(tip);

        var details = document.getElementById("details");
        flameGraph.setDetailsElement(details);

        d3.select("#my-flamegraph")
            .datum(data)
            .call(flameGraph);

        // flamegraph functions
        function handleErrors(vis, res, options) {
          var check = function (group, noun, count, min, max) {
              if (!vis.addError || !vis.clearErrors) {
                  return false;
              }
              if (count < min) {
                  vis.addError({
                      title: "Not Enough " + noun + "s",
                      message: "This visualization requires " + (min === max ? 'exactly' : 'at least') + " " + min + " " + noun.toLowerCase() + (min === 1 ? '' : 's') + ".",
                      group: group
                  });
                  return false;
              }
              if (count > max) {
                  vis.addError({
                      title: "Too Many " + noun + "s",
                      message: "This visualization requires " + (min === max ? 'exactly' : 'no more than') + " " + max + " " + noun.toLowerCase() + (min === 1 ? '' : 's') + ".",
                      group: group
                  });
                  return false;
              }
              vis.clearErrors(group);
              return true;
          };
          var _a = res.fields, pivots = _a.pivots, dimensions = _a.dimensions, measures = _a.measure_like;
          return (check('pivot-req', 'Pivot', pivots.length, options.min_pivots, options.max_pivots)
              && check('dim-req', 'Dimension', dimensions.length, options.min_dimensions, options.max_dimensions)
              && check('mes-req', 'Measure', measures.length, options.min_measures, options.max_measures));
        }

        function stepwise_scale(data, scaler) {
          // console.log('step: ' + data["name"] + ' ' + data["value"]);
          children_total = 0;

          // no children - exit
          if (data["children"].length==0){
            return;
          }

          // get total of children values
          for (var i=0; i<data["children"].length; i++) {
            children_total += data["children"][i]["value"]; 
          }
          // console.log(children_total);

          // scale children's values up to scaler
          if (data["value"] / scaler > children_total) {
            for (var i=0; i<data["children"].length; i++) {
              percent_scale = data["children"][i]["value"]/children_total;
              new_value = Math.round(percent_scale*(data["value"] / scaler));
              console.log('scaling step: ' + data["children"][i]["name"] + ' from ' + data["children"][i]["value"] + ' to ' + new_value);
              data["children"][i]["value"]=new_value;
            }
          }

          // recurse through children
          for (var i=0; i<data["children"].length; i++) {
            stepwise_scale(data["children"][i], scaler);
          }
        }

        function resetZoom() {
          flameGraph.resetZoom();
        }

        function onClick(d) {
          console.info(`Clicked on ${d.data.name}, id: "${d.id}"`);
          history.pushState({ id: d.id }, d.data.name, `#${d.id}`);
        }
    }
};
looker.plugins.visualizations.add(vis);