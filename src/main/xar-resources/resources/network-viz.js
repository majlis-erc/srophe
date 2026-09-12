(function(){
  console.log('network-viz.js loaded');

  // Turn a raw relationship name into a readable label for display:
  //   "snap:motherInLawOf" -> "Mother in law of"
  //   "majlis:relationWith" -> "Relation with"
  // Drops the namespace prefix, splits camelCase, and Sentence-cases the result.
  function formatRel(rel){
    if(!rel) return '';
    var s = String(rel)
      .replace(/^[^:\s]*:/, '')          // drop "snap:" / "majlis:" ... prefix
      .replace(/[_-]+/g, ' ')            // underscores / dashes -> spaces
      .replace(/([a-z0-9])([A-Z])/g, '$1 $2')  // camelCase -> "camel Case"
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
    return s ? s.charAt(0).toUpperCase() + s.slice(1) : '';
  }

  // Entity types that have a real page to link to (matches app:entity-metadata
  // in app.xql, which only recognizes these). "org" nodes appear in the graph
  // but have no known route, so they're excluded here.
  var LINKABLE_TYPES = {manuscript:1, person:1, place:1, work:1};

  // Build the URL for a node's entity page, e.g. node {id:"person10", type:"person"}
  // -> "/exist/apps/majlis/person/10". Returns null for types with no known route.
  function entityUrl(d) {
    if (!d || !LINKABLE_TYPES[d.type]) return null;
    var navBase = (window.networkEntityData && window.networkEntityData.navBase) || '';
    var numericId = d.id.indexOf(d.type) === 0 ? d.id.slice(d.type.length) : d.id;
    return navBase + '/' + d.type + '/' + numericId;
  }

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
      // Height scales with the size of the network: a 2-3 node graph gets a short
      // box, a busy one grows up to the cap. The 620px in the XSL is just a
      // pre-JS fallback.
      var H = Math.max(340, Math.min(720, 260 + this.nodes.length * 30));
      container.style.height = H + 'px';

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
          // r stays the raw value (it is the filter key, matched against l.rel);
          // only the visible label is prettified.
          var label = formatRel(r) || r || '(unspecified)';
          var row = document.createElement('div');
          row.style.cssText = 'display:flex;align-items:center;gap:8px;padding:6px 12px;cursor:pointer';
          row.innerHTML = '<input type="checkbox" checked id="rt-'+safe+'" style="margin:0;cursor:pointer">'
            +'<label for="rt-'+safe+'" style="color:#111;font-size:12px;cursor:pointer">'+label+'</label>';
          row.querySelector('input').addEventListener('change',function(e){
            e.target.checked ? self.hiddenRel.delete(r) : self.hiddenRel.add(r);
            self.applyFilters(self.hiddenEnt, self.hiddenRel);
          });
          rfEl.appendChild(row);
        });
      }

      // Space the layout out to roughly fill the container: a small graph gets a
      // much larger link distance / repulsion than a busy one. fitToContainer()
      // below then pans+zooms whatever the simulation settles on to fill the box.
      var N = Math.max(this.nodes.length, 2);
      var usable = Math.max(1, (W - 60)) * Math.max(1, (H - 60));
      // *0.8 (was 0.95) keeps small graphs compact enough that even a straight
      // chain fits at scale 1, so fitToContainer never has to shrink them below
      // native size (which made e.g. person/46 look tiny next to clustered graphs).
      var linkDist = Math.max(110, Math.min(300, Math.sqrt(usable / N) * 0.8));
      var chargeStr = -Math.max(500, Math.min(2600, linkDist * 7));
      var collideR = Math.max(38, linkDist * 0.30);
      this.spread = linkDist * 0.6;

      // Seed positions on a wide, flat ellipse (not a circle): the container is
      // wide but short, so a landscape layout fits the height without a taller box.
      var cx = W/2, cy = H/2;
      this.nodes.forEach(function(n,i){
        var a = (i/self.nodes.length)*2*Math.PI;
        n.x = cx + self.spread*1.6*Math.cos(a);
        n.y = cy + self.spread*0.65*Math.sin(a);
        n.fx = null; n.fy = null;
      });

      // Create D3 force simulation. forceY is much stronger than forceX so the
      // graph settles as a short horizontal band that fits the container height;
      // forceX is weak so it is free to spread across the (plentiful) width.
      var sim = this.sim = d3.forceSimulation(this.nodes)
        .force('link', d3.forceLink(this.links).id(function(d){return d.id;}).distance(linkDist).strength(0.4))
        .force('charge', d3.forceManyBody().strength(chargeStr))
        .force('center', d3.forceCenter(W/2, H/2).strength(0.03))
        .force('collision', d3.forceCollide(collideR))
        .force('x', d3.forceX(W/2).strength(0.02))
        .force('y', d3.forceY(H/2).strength(0.09));

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
          // Initial of the formatted relationship (so "snap:fatherOf" shows "F",
          // not "S" from the namespace prefix). If a link has no relation type,
          // show nothing instead of a white dot ("•") that looked like part of a
          // nearby entity circle.
          var f = formatRel(d.rel);
          return f ? f.charAt(0).toUpperCase() : '';
        });

      // Tooltip interactions
      var tip = document.getElementById('network-tip');
      this.relG.on('mouseover',function(event,d){
          var sources = d.sources || [];
          var s = sources.map(function(src,i){
            return '<span style="display:block;padding-left:10px;text-indent:-10px"><b>['+(i+1)+']</b> '+src+'</span>';
          }).join('');
          tip.innerHTML = '<b style="font-size:12px;color:#111">'+(formatRel(d.rel)||'relation')+'</b><div style="margin-top:4px;color:#555;font-size:10.5px">'+s+'</div>';
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
        .on('click',function(event,d){
          event.stopPropagation();
          self.highlight(d);
        })
        .on('dblclick',function(event,d){
          event.stopPropagation();
          var url = entityUrl(d);
          if (url) window.open(url, '_blank', 'noopener');
        });

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
        // Long names (e.g. full manuscript shelfmarks) are truncated so they
        // don't run off the right edge / force the graph off-centre; the full
        // name is on the <title> hover.
        .text(function(d){ return d.name.length > 24 ? d.name.slice(0,23) + '…' : d.name; })
        .append('title').text(function(d){
          return LINKABLE_TYPES[d.type] ? d.name + ' (double-click to view page)' : d.name;
        });

      // Click on SVG to deselect
      document.getElementById('network-svg').addEventListener('click',function(){
        self.closePanels(); self.clearHighlight();
      });

      // Animation loop
      sim.on('tick', function(){self.tick(W,H,NR,RR);});
      sim.on('end',  function(){self.fitToContainer(W,H);});
      this._W = W; this._H = H;

      // d3's simulation timer fires the first 'tick' asynchronously (next
      // animation frame), so without this, the just-created node/relation <g>
      // elements have no transform yet and briefly sit stacked at (0,0) - a
      // relation circle can flash on top of a node circle before that first
      // tick runs. Position everything once, synchronously, before that gap.
      this.tick(W, H, NR, RR);
    },

    tick: function(W, H, NR, RR){
      var self = this;
      // X is left loose (width is plentiful; fitToContainer() frames it). Y is
      // held to a horizontal band ~0.72 of the container height, so a graph can
      // never settle taller than the box - it just spreads sideways instead.
      var yTop = 0.14*H, yBot = 0.86*H;
      this.nodes.forEach(function(n){
        n.x = Math.max(-0.3*W, Math.min(1.3*W, n.x));
        n.y = Math.max(yTop, Math.min(yBot, n.y));
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

      this.fitToContainer(W, H);
    },

    // Pan + zoom the #network-viewport group so the whole graph is framed inside
    // the container with a bit of padding. Scale is clamped (see below) so a
    // sparse graph is enlarged only modestly and a dense one shrunk only as far
    // as needed.
    fitToContainer: function(W, H){
      var self = this;
      var vp = d3.select('#network-viewport');
      if(!vp.node() || !this.nodes.length) return;
      // frame only the visible nodes (fall back to all if a filter hid them all)
      var vis = this.nodes.filter(function(n){ return !self.hiddenEnt.has(n.type); });
      if(!vis.length) vis = this.nodes;
      var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
      vis.forEach(function(n){
        if(n.x<minX)minX=n.x; if(n.x>maxX)maxX=n.x;
        if(n.y<minY)minY=n.y; if(n.y>maxY)maxY=n.y;
      });
      var bw=Math.max(1,maxX-minX), bh=Math.max(1,maxY-minY);
      // Padding reserved for the overlay UI: the button column + search box
      // (top-left) and the node name labels, which extend to the right of each
      // circle and are not part of the x/y extent measured above.
      var padT=54, padB=28, padL=60, padR=150;
      var availW=Math.max(60, W-padL-padR), availH=Math.max(60, H-padT-padB);
      var scale=Math.min(availW/bw, availH/bh);
      // Small graphs render roughly 0.85x - 1.4x: kept close to native size for
      // consistency across networks; larger graphs may zoom further out.
      var small=this.nodes.length<=10;
      scale=Math.max(small?0.85:0.35, Math.min(scale, small?1.4:1.8));
      // Centre the node cluster on the container (nudged slightly left so the
      // right-hand labels keep a little room), then push back in if an edge
      // would land under the top-left controls / off the top or bottom.
      var tx=(W/2 - 15) - (minX + bw/2)*scale;
      var ty=(H/2)      - (minY + bh/2)*scale;
      if(minX*scale + tx < padL) tx = padL - minX*scale;
      if(minY*scale + ty < padT) ty = padT - minY*scale;
      if(maxY*scale + ty > H-padB) ty = (H-padB) - maxY*scale;
      vp.attr('transform','translate('+tx+','+ty+') scale('+scale+')');
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
      // re-frame on the now-visible subset
      this.fitToContainer(this._W || 720, this._H || 620);
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
      var W = container.offsetWidth || 720, H = this._H || container.offsetHeight || 620;
      var cx = W/2, cy = H/2, spread = this.spread || Math.min(W,H)*0.33;
      this.nodes.forEach(function(n,i){
        var a = (i/this.nodes.length)*2*Math.PI;
        n.x = cx + spread*1.6*Math.cos(a);
        n.y = cy + spread*0.65*Math.sin(a);
        n.fx = null; n.fy = null;
      }.bind(this));
      d3.select('#network-viewport').attr('transform', null);
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
