(function(){
  console.log('network-viz.js loaded');
  var networkViz = window.networkViz = {
    initialized: false,
    data: null,
    nodes: [],
    links: [],
    sim: null,
    nodeG: null,
    relG: null,
    linkA: null,
    linkB: null,
    hiddenEnt: new Set(),
    hiddenRel: new Set(),

    // Fetch JSON data from deployed majlis-data
    fetchData: function(entityType, entityId) {
      var self = this;
      var url = '/exist/apps/majlis-data/data/' + entityType + '/rel/' + entityId + '.json';
      console.log('Fetching network data from:', url);

      return fetch(url)
        .then(function(response) {
          if (!response.ok) {
            console.warn('Network data not found (HTTP ' + response.status + ') for ' + entityType + '/' + entityId);
            return null;
          }
          return response.json().then(function(data) {
            console.log('Network data loaded:', data);
            return data;
          });
        })
        .catch(function(error) {
          console.error('Error fetching network data from ' + url + ':', error);
          return null;
        });
    },

    init: function(graphData){
      if(this.initialized || !graphData || !graphData.nodes || graphData.nodes.length === 0) {
        console.warn('Cannot initialize network visualization:', {
          initialized: this.initialized,
          hasData: !!graphData,
          hasNodes: graphData && !!graphData.nodes,
          nodeCount: graphData && graphData.nodes ? graphData.nodes.length : 0
        });
        return;
      }
      console.log('Initializing network visualization with', graphData.nodes.length, 'nodes and', graphData.links.length, 'links');
      this.initialized = true;
      this.data = graphData;
      this.nodes = graphData.nodes || [];
      this.links = graphData.links || [];
      this.render();
    },

    render: function(){
      console.log('render() called with', this.nodes.length, 'nodes and', this.links.length, 'links');
      var self = this;
      var container = document.getElementById('network-container');
      if (!container) {
        console.error('network-container element not found - cannot render network visualization');
        console.log('Available elements:', document.querySelectorAll('[id*="network"]').length, 'with id containing "network"');
        return;
      }
      console.log('Found network-container, size:', container.offsetWidth, 'x', container.offsetHeight);

      var W = container.offsetWidth || 720;
      var H = 620;

      var COLORS = {manuscript:'#00883A',person:'#009FE3',place:'#8C4091',work:'#F18700',org:'#C0392B'};
      var ICONS  = {manuscript:'M',person:'P',place:'L',work:'W',org:'O'};
      var NR = 14, RR = 7;
      var LABEL_FS = 13, ICON_FS = 10, REL_FS = 8;

      var entityTypes = [...new Set(this.nodes.map(function(d){return d.type;}))];
      var relTypes    = [...new Set(this.links.map(function(d){return d.rel;}))];
      this.hiddenEnt = new Set();
      this.hiddenRel = new Set();

      // Populate entity type filters
      var efEl = document.getElementById('ef');
      if (efEl) {
        efEl.innerHTML = '';
        entityTypes.forEach(function(t){
          var row = document.createElement('div');
          row.style.cssText = 'display:flex;align-items:center;gap:8px;padding:6px 12px;cursor:pointer';
          row.innerHTML = '<div style="width:10px;height:10px;border-radius:50%;background:'+COLORS[t]+';flex-shrink:0;border:1.5px solid rgba(0,0,0,.15)"></div>'
            +'<input type="checkbox" checked id="et-'+t+'" style="margin:0;cursor:pointer">'
            +'<label for="et-'+t+'" style="color:#111;font-size:12px;cursor:pointer">'+t.charAt(0).toUpperCase()+t.slice(1)+'</label>';
          row.querySelector('input').addEventListener('change',function(e){
            e.target.checked ? self.hiddenEnt.delete(t) : self.hiddenEnt.add(t);
            self.applyFilters(self.hiddenEnt, self.hiddenRel);
          });
          efEl.appendChild(row);
        });
      }

      // Populate relationship type filters
      var rfEl = document.getElementById('rf');
      if (rfEl) {
        rfEl.innerHTML = '';
        relTypes.forEach(function(r){
          var safe = r.replace(/\s/g,'_');
          var row = document.createElement('div');
          row.style.cssText = 'display:flex;align-items:center;gap:8px;padding:6px 12px;cursor:pointer';
          row.innerHTML = '<input type="checkbox" checked id="rt-'+safe+'" style="margin:0;cursor:pointer">'
            +'<label for="rt-'+safe+'" style="color:#111;font-size:12px;cursor:pointer">'+r+'</label>';
          row.querySelector('input').addEventListener('change',function(e){
            e.target.checked ? self.hiddenRel.delete(r) : self.hiddenRel.add(r);
            self.applyFilters(self.hiddenEnt, self.hiddenRel);
          });
          rfEl.appendChild(row);
        });
      }

      // Initialize node positions in a circle
      var cx = W/2, cy = H/2;
      this.nodes.forEach(function(n,i){
        var a = (i/self.nodes.length)*2*Math.PI;
        n.x = cx + Math.min(W,H)*0.33*Math.cos(a);
        n.y = cy + Math.min(W,H)*0.33*Math.sin(a);
        n.fx = null; n.fy = null;
      });

      // Create D3 force simulation
      var sim = this.sim = d3.forceSimulation(this.nodes)
        .force('link', d3.forceLink(this.links).id(function(d){return d.id;}).distance(160).strength(0.45))
        .force('charge', d3.forceManyBody().strength(-650))
        .force('center', d3.forceCenter(W/2, H/2).strength(0.06))
        .force('collision', d3.forceCollide(50))
        .force('x', d3.forceX(W/2).strength(0.04))
        .force('y', d3.forceY(H/2).strength(0.04));

      var svg = d3.select('#network-svg');
      console.log('SVG element selected:', svg.node() ? 'found' : 'NOT FOUND');
      if (!svg.node()) {
        console.error('Cannot find SVG with id="network-svg"');
        console.log('Document has', document.querySelectorAll('svg').length, 'SVG elements total');
        return;
      }

      // Link visual (lines)
      this.linkA = svg.select('#ll').selectAll('line.la').data(this.links).join('line')
        .attr('class','la').attr('stroke','#ccc').attr('stroke-width',1);
      this.linkB = svg.select('#ll').selectAll('line.lb').data(this.links).join('line')
        .attr('class','lb').attr('stroke','#ccc').attr('stroke-width',1).attr('marker-end','url(#arr)');

      // Relationship circles (labels on edges)
      this.relG = svg.select('#rl').selectAll('g').data(this.links).join('g').style('cursor','pointer');
      this.relG.append('circle').attr('r',RR).attr('fill','#222').attr('stroke','#fff').attr('stroke-width',1.5);
      this.relG.append('text')
        .attr('text-anchor','middle').attr('dominant-baseline','central')
        .attr('font-size',REL_FS).attr('font-weight','700').attr('fill','#fff').attr('pointer-events','none')
        .text(function(d){
          if(d.rel && d.rel.length > 0) return d.rel[0].toUpperCase();
          return '•';
        });

      // Tooltip interactions
      var tip = document.getElementById('network-tip');
      this.relG.on('mouseover',function(event,d){
          var sources = d.sources || [];
          var s = sources.map(function(src,i){
            return '<span style="display:block;padding-left:10px;text-indent:-10px"><b>['+(i+1)+']</b> '+src+'</span>';
          }).join('');
          tip.innerHTML = '<b style="font-size:12px;color:#111">'+(d.rel||'relation')+'</b><div style="margin-top:4px;color:#555;font-size:10.5px">'+s+'</div>';
          tip.style.opacity = '1';
        })
        .on('mousemove',function(event){
          var rc = container.getBoundingClientRect();
          tip.style.left = (event.clientX-rc.left+12)+'px';
          tip.style.top  = (event.clientY-rc.top-10)+'px';
        })
        .on('mouseout',function(){tip.style.opacity='0';});

      // Node elements
      this.nodeG = svg.select('#nl').selectAll('g').data(this.nodes).join('g')
        .style('cursor','pointer')
        .call(d3.drag()
          .on('start',function(e){if(!e.active)sim.alphaTarget(0.3).restart();e.subject.fx=e.subject.x;e.subject.fy=e.subject.y;})
          .on('drag', function(e){e.subject.fx=e.x;e.subject.fy=e.y;})
          .on('end',  function(e){if(!e.active)sim.alphaTarget(0);e.subject.fx=null;e.subject.fy=null;}))
        .on('click',function(event,d){event.stopPropagation();self.highlight(d);});

      this.nodeG.append('circle').attr('r',NR)
        .attr('fill',function(d){return COLORS[d.type];}).attr('stroke','#fff').attr('stroke-width',2);
      this.nodeG.append('text')
        .attr('text-anchor','middle').attr('dominant-baseline','central')
        .attr('font-size',ICON_FS).attr('font-weight','700').attr('fill','#fff').attr('pointer-events','none')
        .text(function(d){return ICONS[d.type];});
      this.nodeG.append('rect').attr('rx',3)
        .attr('fill','#fff').attr('stroke','#ddd').attr('stroke-width',0.5).attr('pointer-events','none');
      this.nodeG.append('text')
        .attr('x', NR + 5).attr('dominant-baseline','central')
        .attr('font-size',LABEL_FS).attr('fill','#222').attr('pointer-events','none')
        .text(function(d){return d.name;});

      // Click on SVG to deselect
      document.getElementById('network-svg').addEventListener('click',function(){
        self.closePanels(); self.clearHighlight();
      });

      // Animation loop
      sim.on('tick', function(){self.tick(W,H,NR,RR);});
    },

    tick: function(W, H, NR, RR){
      var self = this;
      this.nodes.forEach(function(n){
        n.x = Math.max(16, Math.min(W-190, n.x));
        n.y = Math.max(16, Math.min(H-16,  n.y));
      });

      function shorten(x1,y1,x2,y2,r){
        var dx=x2-x1,dy=y2-y1,len=Math.sqrt(dx*dx+dy*dy)||1;
        return {x:x2-dx/len*r, y:y2-dy/len*r};
      }

      this.linkA.each(function(d){
        var m={x:(d.source.x+d.target.x)/2,y:(d.source.y+d.target.y)/2};
        var s=shorten(m.x,m.y,d.source.x,d.source.y,NR);
        var e=shorten(d.source.x,d.source.y,m.x,m.y,RR);
        d3.select(this).attr('x1',s.x).attr('y1',s.y).attr('x2',e.x).attr('y2',e.y);
      });
      this.linkB.each(function(d){
        var m={x:(d.source.x+d.target.x)/2,y:(d.source.y+d.target.y)/2};
        var s=shorten(d.target.x,d.target.y,m.x,m.y,RR);
        var e=shorten(m.x,m.y,d.target.x,d.target.y,NR);
        d3.select(this).attr('x1',s.x).attr('y1',s.y).attr('x2',e.x).attr('y2',e.y);
      });
      this.relG.attr('transform',function(d){
        return 'translate('+(d.source.x+d.target.x)/2+','+(d.source.y+d.target.y)/2+')';
      });
      this.nodeG.attr('transform',function(d){return 'translate('+d.x+','+d.y+')';});
      this.nodeG.each(function(){
        var texts=d3.select(this).selectAll('text').nodes();
        var lbl=texts[texts.length-1];
        if(lbl){
          var b=lbl.getBBox();
          d3.select(this).select('rect')
            .attr('x',b.x-3).attr('y',b.y-2)
            .attr('width',b.width+6).attr('height',b.height+4);
        }
      });
    },

    highlight: function(d){
      var self = this;
      var conn=new Set([d.id]);
      this.links.forEach(function(l){
        if(l.source.id===d.id) conn.add(l.target.id);
        if(l.target.id===d.id) conn.add(l.source.id);
      });
      this.nodeG.attr('opacity',function(n){return conn.has(n.id)?1:0.1;});
      this.linkA.attr('opacity',function(l){return l.source.id===d.id||l.target.id===d.id?1:0.05;});
      this.linkB.attr('opacity',function(l){return l.source.id===d.id||l.target.id===d.id?1:0.05;});
      this.relG.attr('opacity', function(l){return l.source.id===d.id||l.target.id===d.id?1:0.05;});
    },

    clearHighlight: function(){
      this.nodeG.attr('opacity',1);
      this.linkA.attr('opacity',1); this.linkB.attr('opacity',1);
      this.relG.attr('opacity',1);
    },

    applyFilters: function(hiddenEnt, hiddenRel){
      var tm={};
      this.nodes.forEach(function(n){tm[n.id]=n.type;});
      function hidden(l){
        if(hiddenRel.has(l.rel)) return true;
        var si=typeof l.source==='object'?l.source.id:l.source;
        var ti=typeof l.target==='object'?l.target.id:l.target;
        return hiddenEnt.has(tm[si])||hiddenEnt.has(tm[ti]);
      }
      this.nodeG.attr('display',function(d){return hiddenEnt.has(d.type)?'none':null;});
      this.linkA.attr('display',function(l){return hidden(l)?'none':null;});
      this.linkB.attr('display',function(l){return hidden(l)?'none':null;});
      this.relG.attr('display', function(l){return hidden(l)?'none':null;});
    },

    closePanels: function(){
      var panelEntities = document.getElementById('panel-entities');
      var panelRels = document.getElementById('panel-rels');
      if (panelEntities) panelEntities.style.transform = 'translateX(100%)';
      if (panelRels) panelRels.style.transform = 'translateX(100%)';
    },

    togglePanel: function(name, event){
      if(event) event.stopPropagation();
      var p = document.getElementById('panel-'+name);
      if (!p) return;
      var open = p.style.transform === 'translateX(0px)' || p.style.transform === 'translateX(0)';
      this.closePanels();
      if(!open){
        p.style.transform = 'translateX(0)';
      }
    },

    relayout: function(event){
      if(event) event.stopPropagation();
      this.clearHighlight();
      var searchInput = document.getElementById('network-search');
      if (searchInput) searchInput.value = '';
      var container = document.getElementById('network-container');
      var W = container.offsetWidth || 720, H = 620;
      var cx = W/2, cy = H/2;
      this.nodes.forEach(function(n,i){
        var a = (i/this.nodes.length)*2*Math.PI;
        n.x = cx + Math.min(W,H)*0.33*Math.cos(a);
        n.y = cy + Math.min(W,H)*0.33*Math.sin(a);
        n.fx = null; n.fy = null;
      }.bind(this));
      this.sim.alpha(1).restart();
    },

    doSearch: function(term){
      term = term.toLowerCase().trim();
      if(!term){ this.clearHighlight(); return; }
      this.nodeG.attr('opacity',function(d){return d.name.toLowerCase().includes(term)?1:0.1;});
      var self = this;
      function linkMatch(l){
        var sn=typeof l.source==='object'?l.source.name:l.source;
        var tn=typeof l.target==='object'?l.target.name:l.target;
        return sn.toLowerCase().includes(term)||tn.toLowerCase().includes(term);
      }
      this.linkA.attr('opacity',function(l){return linkMatch(l)?1:0.05;});
      this.linkB.attr('opacity',function(l){return linkMatch(l)?1:0.05;});
      this.relG.attr('opacity', function(l){return linkMatch(l)?1:0.05;});
    }
  };

})();

// Auto-initialize if networkEntityData is available
console.log('network-viz.js finished loading, checking for auto-init...');
(function() {
  var attempts = 0;
  function autoInit() {
    attempts++;
    if (attempts > 100) {
      console.log('Auto-init gave up after', attempts * 100, 'ms');
      return;
    }
    if (!window.networkEntityData) {
      setTimeout(autoInit, 100);
      return;
    }
    console.log('Auto-initializing with:', window.networkEntityData);
    window.networkViz.fetchData(window.networkEntityData.type, window.networkEntityData.id)
      .then(function(data) {
        if (data && data.nodes && data.nodes.length > 0) {
          // Show the network visualization section and button BEFORE init
          var sectionId = 'network-viz-section-' + window.networkEntityData.singular;
          var btnId = 'btn-network-group-' + window.networkEntityData.singular;
          console.log('Showing network elements:', sectionId, btnId);
          var vizSection = document.getElementById(sectionId);
          var btnGroup = document.getElementById(btnId);
          if (vizSection) {
            vizSection.style.display = '';
            console.log('Showed network visualization section');
          }
          if (btnGroup) {
            btnGroup.style.display = '';
            console.log('Showed network button group');
          }

          // Now initialize with visible container
          window.networkViz.init(data);
          console.log('Auto-initialization complete');
        } else {
          console.log('No network data available for this entity');
        }
      })
      .catch(function(e) {
        console.error('Auto-init error:', e);
      });
  }
  setTimeout(autoInit, 500);  // Wait 500ms for everything to settle
})();
