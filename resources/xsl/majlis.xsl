<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:x="http://www.w3.org/1999/xhtml" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://syriaca.org/ns"
    exclude-result-prefixes="xs t x saxon local" version="2.0">
    <!-- ================================================================== 
       MAJLIS custom srophe XSLT
       For main record display, manuscript
       
       ================================================================== -->

    <xsl:template match="t:TEI" mode="majlis">
        <!-- teiHeader -->
        <div class="row titleStmt">
            <div class="col-md-8">
                <h1>
                    <xsl:choose>
                        <xsl:when test="t:teiHeader/t:fileDesc/t:titleStmt/t:title[@level = 'a']">
                            <xsl:apply-templates
                                select="t:teiHeader/t:fileDesc/t:titleStmt/t:title[@level = 'a']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates
                                select="t:teiHeader/t:fileDesc/t:titleStmt/t:title[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
            </div>
            <div class="col-md-4 actionButtons">
                <xsl:if test="t:TEI/t:facsimile/t:graphic/@url">
                    <a class="btn btn-default btn-grey btn-sm"
                        href="{t:TEI/t:facsimile/t:graphic/@url}" target="_blank" type="button"
                        >Scan</a>
                </xsl:if>
                <a class="btn btn-default btn-grey btn-sm" href="" type="button">Feedback</a>
                <a class="btn btn-default btn-grey btn-sm"
                    href="{concat($nav-base,substring-after(/descendant::t:idno[@type='URI'][1], $base-uri))}"
                    >XML</a>
                <a class="btn btn-default btn-grey btn-sm" href="javascript:window.print();"
                    >Print</a>
            </div>
        </div>
        <xsl:choose>
            <xsl:when test="descendant::t:text/t:body/t:listBibl/t:msDesc">
                <xsl:apply-templates mode="majlis-mss" select="descendant::t:body"/>
            </xsl:when>
            <xsl:when test="descendant::t:text/t:body/t:listPerson">
                <xsl:apply-templates mode="majlis-person" select="descendant::t:body"/>
            </xsl:when>
            <xsl:when test="descendant::t:text/t:body/t:bibl">
                <xsl:apply-templates mode="majlis-work" select="descendant::t:body"/>
            </xsl:when>
            <xsl:when test="descendant::t:text/t:body/t:listPlace">
                <xsl:apply-templates mode="majlis-place" select="descendant::t:body"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="whiteBoxwShadow">
                    <xsl:apply-templates select="descendant::t:body"/>
                    <xsl:apply-templates select="descendant::t:teiHeader"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        <script type="text/javascript">       
        <![CDATA[
            //show or collapse all
            $('#expand-all').click(function () {
                var $myGroup = $('#mainMenu');
                var label = $(this).text()
                console.log(label);
                if (label === "Open All") {
                    console.log('open');
                    $myGroup.find('.collapse').collapse('show');
                    $(this).text("Close All");
                } else {
                    console.log('close');
                    $myGroup.find('.collapse').collapse('hide');
                    $(this).text("Open All");
                }
            });
            $('.expandFromAnchor').click(function () {
                var $myGroup = $('#mainMenu');
                $myGroup.find('.collapse').collapse('show');
            });//]]>
        </script>
    </xsl:template>
    <xsl:template match="t:body" mode="majlis majlis-mss">
        <xsl:if test="t:listBibl/t:msDesc/t:msContents/t:msItem">
            <xsl:for-each select="t:listBibl/t:msDesc[1]">
                <div class="mainDesc row">
                    <div class="col-md-6">
                        <xsl:if test="t:msContents/t:msItem/t:title[1][. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Title</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:msContents/t:msItem/t:title[1][. != '']">
                                        <xsl:apply-templates mode="majlis" select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:msContents/t:msItem/t:author[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Author</span>
                                <span class="col-md-9">
                                    <xsl:for-each-group group-by="text()"
                                        select="t:msContents/t:msItem/t:author[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each-group>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:msContents/t:msItem/t:textLang[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Language</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:msContents/t:msItem/t:textLang[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:history/t:origin/t:persName[@role = 'scribe'][. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Scribe</span>
                                <span class="col-md-9">
                                    <xsl:for-each
                                        select="t:history/t:origin/t:persName[@role = 'scribe'][. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                    </div>
                    <div class="col-md-6">
                        <xsl:if test="t:history/t:origin/t:origDate[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Date</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:history/t:origin/t:origDate[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:history/t:origin/t:origPlace[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Place</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:history/t:origin/t:origPlace[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:physDesc/t:objectDesc/@form[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Object Type</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:physDesc/t:objectDesc/@form">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if
                            test="t:physDesc/t:objectDesc/t:supportDesc/t:support/t:material[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Material</span>
                                <span class="col-md-9">
                                    <xsl:for-each
                                        select="t:physDesc/t:objectDesc/t:supportDesc/t:support/t:material[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="physDesc/objectDesc/supportDesc/extent/measure[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Extent</span>
                                <span class="col-md-9">
                                    <xsl:for-each
                                        select="physDesc/objectDesc/supportDesc/extent/measure[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                    </div>
                </div>
            </xsl:for-each>
        </xsl:if>
        <div class="listEntities row">
            <div class="col-md-4 text-left">
                <button aria-expanded="true" class="btn btn-default btn-lg" data-toggle="collapse"
                    href="#personEntities" type="button">Persons</button>
                <xsl:call-template name="personEntities"/>
            </div>
            <div class="col-md-4 text-center">
                <button aria-expanded="true" class="btn btn-default btn-lg" data-toggle="collapse"
                    href="#placeEntities" type="button">Places</button>
                <xsl:call-template name="placeEntities"/>
            </div>
            <div class="col-md-4 text-right">
                <button aria-expanded="true" class="btn btn-default btn-lg" data-toggle="collapse"
                    href="#workEntities" type="button">Works</button>
                <xsl:call-template name="workEntities"/>
            </div>
        </div>
        <!-- Menu items for record contents -->
        <!-- aria-expanded="false" -->
        <xsl:variable name="Content">
            <xsl:apply-templates mode="majlis" select="t:listBibl/t:msDesc/t:msContents"/>
        </xsl:variable>
        <xsl:variable name="Codicology">
            <xsl:apply-templates mode="majlis" select="t:listBibl/t:msDesc/t:physDesc/t:objectDesc"
            />
        </xsl:variable>
        <xsl:variable name="Paleography">
            <xsl:apply-templates mode="majlis" select="t:listBibl/t:msDesc/t:physDesc/t:handDesc"/>
        </xsl:variable>
        <xsl:variable name="incodicatedDocuments">
            <xsl:apply-templates mode="majlis" select="t:listBibl/t:msDesc/t:physDesc/t:additions"/>
        </xsl:variable>
        <xsl:variable name="History">
            <xsl:apply-templates mode="majlis" select="t:listBibl/t:msDesc/t:history"/>
        </xsl:variable>
        <xsl:variable name="Heritage">
            <xsl:apply-templates mode="majlis" select="t:listBibl/t:msDesc/t:physDesc/t:accMat"/>
        </xsl:variable>
        <xsl:variable name="Bibliography">
            <xsl:apply-templates mode="majlisAdditional"
                select="t:listBibl/t:msDesc/t:additional[descendant-or-self::t:listBibl]"/>
        </xsl:variable>
        <xsl:variable name="Credits">
            <xsl:apply-templates mode="majlis-credits"
                select="ancestor::t:TEI/descendant::t:teiHeader/t:fileDesc/t:titleStmt"/>
        </xsl:variable>
        <div id="mainMenu">
            <div class="btn-group btn-group-justified">
                <xsl:if
                    test="$Content/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuContent" type="button"
                            >Content</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Codicology/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuCodicology" type="button">Codicology</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Paleography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuPaleography" type="button">Paleography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$incodicatedDocuments/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuAdditions" type="button">Incodicated Documents</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$History/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuHistory" type="button">History</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Heritage/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuHeritage" type="button">Heritage Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuBibliography" type="button">Bibliography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuCredits" type="button">Credits</button>
                    </div>
                </xsl:if>
                <div class="btn-group">
                    <button class="btn btn-default btn-grey btn-lg" id="expand-all" type="button"
                        >Open All</button>
                </div>
            </div>
            <div class="mainMenuContent">
                <xsl:if
                    test="$Content/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$Content"/>
                </xsl:if>
                <xsl:if
                    test="$Codicology/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$Codicology"/>
                </xsl:if>
                <xsl:if
                    test="$Paleography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$Paleography"/>
                </xsl:if>
                <xsl:if
                    test="$incodicatedDocuments/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$incodicatedDocuments"/>
                </xsl:if>
                <xsl:if
                    test="$History/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$History"/>
                </xsl:if>
                <xsl:if
                    test="$Heritage/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$Heritage"/>
                </xsl:if>
                <xsl:if
                    test="$Bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$Bibliography"/>
                </xsl:if>
                <xsl:if
                    test="$Credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$Credits"/>
                </xsl:if>
                <!--
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:msContents" mode="majlis"/>
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:objectDesc" mode="majlis"/>
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:handDesc" mode="majlis"/>
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:additions" mode="majlis"/>
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:history" mode="majlis"/>
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:accMat" mode="majlis"/>
                <xsl:apply-templates select="t:listBibl/t:msDesc/t:additional/t:listBibl" mode="majlis"/>
                <xsl:apply-templates select="//t:teiHeader/t:fileDesc/t:titleStmt" mode="majlis-credits"/>
                -->
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:body" mode="majlis majlis-person">
        <xsl:for-each select="t:listPerson/t:person">
            <div class="mainDesc row">
                <div class="col-md-6">
                    <xsl:if test="t:state/t:label[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Role</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:state/t:label[. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:birth/t:placeName[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Place of birth</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:birth/t:placeName[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:birth/t:date[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Date of birth</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:birth/t:date[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <!--<xsl:if test="t:floruit/t:placeName[1][. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Place of activity</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:floruit/t:placeName[1][. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:floruit/t:date[1][. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Date of activity</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:floruit/t:date[1][. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>-->
                </div>
                <div class="col-md-6">
                    <xsl:if test="t:death/t:placeName[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Place of death</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:death/t:placeName[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:death/t:date[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Date of death</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:death/t:date[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                </div>
            </div>
        </xsl:for-each>
        <!-- Menu items for record contents -->
        <!-- aria-expanded="false" -->
        <xsl:variable name="majlisNames">
            <xsl:apply-templates mode="names" select="t:listPerson/t:person"/>
        </xsl:variable>
        <xsl:variable name="attestedNames">
            <xsl:apply-templates mode="attestedNames" select="t:listPerson/t:person"/>
        </xsl:variable>
        <xsl:variable name="biography">
            <xsl:apply-templates mode="biography" select="t:listPerson/t:person"/>
        </xsl:variable>
        <xsl:variable name="heritageData">
            <xsl:apply-templates mode="heritageData"
                select="ancestor::t:TEI/descendant::t:standOff/t:list"/>
        </xsl:variable>
        <xsl:variable name="bibliography">
            <xsl:apply-templates mode="person-bibliography" select="t:listPerson/t:person"/>
        </xsl:variable>
        <xsl:variable name="attestations">
            <xsl:apply-templates mode="person-attestations" select="t:listPerson/t:person"/>
        </xsl:variable>
        <xsl:variable name="linkedOpenData">
            <xsl:apply-templates mode="linkedOpenData" select="t:listPerson/t:person"/>
        </xsl:variable>
        <xsl:variable name="credits">
            <xsl:apply-templates mode="majlis-credits"
                select="ancestor::t:TEI/descendant::t:teiHeader/t:fileDesc/t:titleStmt"/>
        </xsl:variable>
        <!-- Add works -->
        <xsl:variable name="works">
            <xsl:apply-templates mode="relatedWorks" select="ancestor::*:result/*:works"/>
        </xsl:variable>
        <div id="mainMenu">
            <div class="btn-group btn-group-justified">
                <xsl:if
                    test="$majlisNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuNames" type="button"
                            >Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$works/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuRelatedWorks" type="button"
                            >Works</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$attestedNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuAttestedNames" type="button">Attested Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$biography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuBiography" type="button">Biography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuBibliography" type="button">Bibliography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$attestations/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuAttestations" type="button">Attestations</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$linkedOpenData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuLinkedOpenData" type="button">Linked Open Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$heritageData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuHeritageData" type="button">Heritage Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuCredits" type="button">Credits</button>
                    </div>
                </xsl:if>
                <div class="btn-group">
                    <button class="btn btn-default btn-grey btn-lg" id="expand-all" type="button"
                        >Open All</button>
                </div>
            </div>
            <div class="mainMenuContent">
                <xsl:if
                    test="$majlisNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$majlisNames"/>
                </xsl:if>
                <xsl:if
                    test="$works/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$works"/>
                </xsl:if>
                <xsl:if
                    test="$attestedNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$attestedNames"/>
                </xsl:if>
                <xsl:if
                    test="$biography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$biography"/>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$bibliography"/>
                </xsl:if>
                <xsl:if
                    test="$attestations/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$attestations"/>
                </xsl:if>
                <xsl:if
                    test="$linkedOpenData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$linkedOpenData"/>
                </xsl:if>
                <xsl:if
                    test="$heritageData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$heritageData"/>
                </xsl:if>
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$credits"/>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:body" mode="majlis majlis-work">
        <xsl:for-each select="t:bibl">
            <div class="mainDesc row">
                <div class="col-md-6">
                    <xsl:if
                        test="t:title[@type = 'canon'][@xml:lang = 'ar' or @xml:lang = 'he'][1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Original title</span>
                            <span class="col-md-9">
                                <xsl:for-each
                                    select="t:title[@type = 'canon'][@xml:lang = 'ar' or @xml:lang = 'he'][1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:author[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Author</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:author[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:persName[@type = 'compilator'][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Compilator</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:persName[@type = 'compilator'][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:persName[@type = 'translator'][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Translator</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:persName[@type = 'translator'][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="ancestor::t:TEI/descendant::t:list/t:item[. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Disciplines</span>
                            <span class="col-md-9">
                                <xsl:for-each
                                    select="ancestor::t:TEI/descendant::t:list/t:item[. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                </div>
                <div class="col-md-6">
                    <xsl:if test="t:date[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Date of composition</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:date[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:term[1][. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Attested in script</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:term[1][. != '']">
                                    <xsl:apply-templates select="."/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                    <xsl:if test="t:textLang/@mainLang[. != '']">
                        <div class="item row">
                            <span class="inline-h4 col-md-3">Text language</span>
                            <span class="col-md-9">
                                <xsl:for-each select="t:textLang/@mainLang[. != '']">
                                    <xsl:value-of select="local:expand-lang(., '')"/>
                                    <xsl:if test="position() != last()">, </xsl:if>
                                </xsl:for-each>
                            </span>
                        </div>
                    </xsl:if>
                </div>
            </div>
        </xsl:for-each>
        <!-- Menu items for record contents -->
        <!-- aria-expanded="false" -->
        <xsl:variable name="title">
            <xsl:apply-templates mode="work-title" select="t:bibl"/>
        </xsl:variable>
        <xsl:variable name="attestedTitles">
            <xsl:apply-templates mode="work-attestedTitles" select="t:bibl"/>
        </xsl:variable>
        <xsl:variable name="attestations">
            <xsl:apply-templates mode="work-attestations" select="ancestor::*:result/*:mss"/>
        </xsl:variable>
        <xsl:variable name="translations">
            <xsl:apply-templates mode="work-translations" select="t:bibl"/>
        </xsl:variable>
        <xsl:variable name="bibliography">
            <xsl:apply-templates mode="work-bibliography" select="t:bibl"/>
        </xsl:variable>
        <xsl:variable name="contentInformation">
            <xsl:apply-templates mode="work-content" select="t:bibl"/>
        </xsl:variable>
        <!--<xsl:variable name="edition">
            <xsl:apply-templates mode="work-edition" select="t:bibl"/>
        </xsl:variable>-->
        <xsl:variable name="credits">
            <xsl:apply-templates mode="majlis-credits"
                select="ancestor::t:TEI/descendant::t:teiHeader/t:fileDesc/t:titleStmt"/>
        </xsl:variable>
        <div id="mainMenu">
            <div class="btn-group btn-group-justified">
                <xsl:if
                    test="$title/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuTitle" type="button"
                            >Title</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$attestedTitles/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuAttestedTitles" type="button">Attested Titles</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$attestations/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuAttestations" type="button">Attestations in
                            Manuscripts</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$translations/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuTranslations" type="button">Translations</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuBibliography" type="button">Bibliography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$contentInformation/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuContentInformation" type="button">Content
                            Information</button>
                    </div>
                </xsl:if>
                <!--<xsl:if test="$edition/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse" href="#mainMenuEdition" type="button">Edition</button>
                    </div>
                </xsl:if>-->
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuCredits" type="button">Credits</button>
                    </div>
                </xsl:if>
                <div class="btn-group">
                    <button class="btn btn-default btn-grey btn-lg" id="expand-all" type="button"
                        >Open All</button>
                </div>
            </div>
            <div class="mainMenuContent">
                <xsl:if
                    test="$title/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$title"/>
                </xsl:if>
                <xsl:if
                    test="$attestedTitles/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$attestedTitles"/>
                </xsl:if>
                <xsl:if
                    test="$attestations/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$attestations"/>
                </xsl:if>
                <xsl:if
                    test="$translations/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$translations"/>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$bibliography"/>
                </xsl:if>
                <xsl:if
                    test="$contentInformation/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$contentInformation"/>
                </xsl:if>
                <!--<xsl:if test="$edition/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$edition"/>
                </xsl:if>-->
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$credits"/>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:body" mode="majlis majlis-place">
        <!-- Menu items for record contents -->
        <!-- aria-expanded="false" -->
        <xsl:variable name="names">
            <xsl:apply-templates mode="place-names" select="t:listPlace/t:place"/>
        </xsl:variable>
        <xsl:variable name="location">
            <xsl:apply-templates mode="place-location" select="t:listPlace/t:place"/>
        </xsl:variable>
        <xsl:variable name="bibliography">
            <xsl:apply-templates mode="place-bibliography" select="t:listPlace/t:place"/>
        </xsl:variable>
        <xsl:variable name="linkedOpenData">
            <xsl:apply-templates mode="place-linkedOpenData" select="t:listPlace/t:place"/>
        </xsl:variable>
        <xsl:variable name="credits">
            <xsl:apply-templates mode="majlis-credits"
                select="ancestor::t:TEI/descendant::t:teiHeader/t:fileDesc/t:titleStmt"/>
        </xsl:variable>
        <div id="mainMenu">
            <div class="btn-group btn-group-justified">
                <xsl:if
                    test="$names/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuNames" type="button"
                            >Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$location/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuLocation" type="button">Location</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuBibliography" type="button">Bibliography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$linkedOpenData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuLinkedOpenData" type="button">Linked Open Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button class="btn btn-default btn-grey btn-lg" data-toggle="collapse"
                            href="#mainMenuCredits" type="button">Credits</button>
                    </div>
                </xsl:if>
                <div class="btn-group">
                    <button class="btn btn-default btn-grey btn-lg" id="expand-all" type="button"
                        >Open All</button>
                </div>
            </div>
            <div class="mainMenuContent">
                <xsl:if
                    test="$names/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$names"/>
                </xsl:if>
                <xsl:if
                    test="$location/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$location"/>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$bibliography"/>
                </xsl:if>
                <xsl:if
                    test="$linkedOpenData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$linkedOpenData"/>
                </xsl:if>
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$credits"/>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="*:mss" mode="work-attestations">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuAttestations"
                    >Attestations in Manuscripts</a>
            </h3>
            <div class="collapse in" id="mainMenuAttestations">
                <xsl:for-each select="t:TEI">
                    <div class="item row">
                        <div class="col-md-12">
                            <a
                                href="{concat($nav-base,substring-after(descendant::t:publicationStmt/t:idno[@type='URI'][1], $base-uri))}">
                                <xsl:apply-templates select="descendant::t:titleStmt/t:title[1]"/>
                            </a>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:msContents" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuContent">Content</a>
            </h3>
            <div class="collapse in" id="mainMenuContent">
                <xsl:if test="t:summary[. != '']">
                    <div class="item row">
                        <div class="col-md-1">
                            <h4>Summary</h4>
                        </div>
                        <div class="col-md-11">
                            <xsl:for-each select="t:summary[string-length(normalize-space(.)) gt 2]">
                                <xsl:apply-templates/>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:if>
                <xsl:for-each select="t:msItem">
                    <div class="row">
                        <div class="col-md-1">
                            <h4>Text <xsl:value-of select="position()"/>
                            </h4>
                        </div>
                        <div class="col-md-11">
                            <xsl:for-each select="child::*[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4 ">
                                        <xsl:variable name="label" select="local-name(.)"/>
                                        <xsl:choose>
                                            <xsl:when test="$label = 'locus'">Folios</xsl:when>
                                            <xsl:when test="$label = 'title'">Title <xsl:if
                                                  test="@xml:lang != ''">[<xsl:value-of
                                                  select="upper-case(@xml:lang)"/>]</xsl:if>
                                            </xsl:when>
                                            <xsl:when test="$label = 'textLang'">Language</xsl:when>
                                            <xsl:when test="$label = 'rubric'">Text
                                                Division</xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
                                                  select="concat(upper-case(substring($label, 1, 1)), substring($label, 2))"
                                                />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                    <div class="col-md-10">
                                        <xsl:choose>
                                            <xsl:when test="local-name(.) = 'title'">
                                                <xsl:apply-templates select="." mode="majlis"/>
                                                <xsl:variable name="locus">
                                                  <xsl:for-each
                                                  select="preceding-sibling::t:locus | following-sibling::t:locus">
                                                  <xsl:call-template name="locus"/>
                                                  </xsl:for-each>
                                                </xsl:variable>
                                                <xsl:if test="$locus != ''"> (<xsl:sequence
                                                  select="$locus"/>) </xsl:if>
                                            </xsl:when>
                                            <xsl:when test="local-name(.) = 'textLang'">
                                                <xsl:for-each select="@otherLangs | @mainLang">
                                                  <xsl:variable name="langCode" select="."/>
                                                  <xsl:value-of
                                                  select="local:expand-lang($langCode, '')"/>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:when test="local-name(.) = ('incipit', 'explicit')">
                                                <!-- WS:NOTE - not applying locus?? -->
                                                <xsl:apply-templates/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:person" mode="names">
        <xsl:if test="t:persName[@type = 'majlis-headword'] | t:persName[@type = 'canon']">
            <div class="whiteBoxwShadow">
                <div class="row">
                    <h3>
                        <a aria-expanded="true" data-toggle="collapse" href="#mainMenuNames"
                            >Names</a>
                    </h3>
                    <div class="collapse" id="mainMenuNames">
                        <div class="row">
                            <script type="text/javascript">
                        <![CDATA[
                            $(document).ready(function () {
                                $("#toggle-english").on("click", function () {
                                    $(this).toggleClass("highlight");
                                    $(".englishNames").toggle();
                                });
                                $("#toggle-hebrew").on("click", function () {
                                    $(this).toggleClass("highlight");
                                    $(".hebrewNames").toggle();
                                });
                                $("#toggle-arabic").on("click", function () {
                                    $(this).toggleClass("highlight");
                                    $(".arabicNames").toggle();
                                });
                            });//]]></script>
                            <div class="col-md-12 inline-h4">
                                <div class="tri-state-toggle">
                                    <span class="tri-state-toggle-button highlight"
                                        href="#englishNames" id="toggle-english">
                                        <span lang="en">E</span>
                                    </span>
                                    <span class="tri-state-toggle-button" data-toggle="collapse"
                                        href="#hebrewNames" id="toggle-hebrew">
                                        <span lang="he">ע</span>
                                    </span>
                                    <span class="tri-state-toggle-button" data-toggle="collapse"
                                        href="#arabicNames" id="toggle-arabic">
                                        <span lang="ar"> ع </span>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <xsl:for-each
                            select="t:persName[@type = 'canon'][string-length(normalize-space(.)) gt 2]">
                            <xsl:variable name="langClass">
                                <xsl:choose>
                                    <xsl:when test="contains(@xml:lang, 'Latn') or @xml:lang = 'en'"
                                        >englishNames</xsl:when>
                                    <xsl:when
                                        test="@xml:lang = 'he' or contains(@xml:lang, 'he') or contains(@xml:lang, 'Hebr')"
                                        >hebrewNames</xsl:when>
                                    <xsl:when
                                        test="@xml:lang = 'ar' or contains(@xml:lang, 'ar') or contains(@xml:lang, 'Arab')"
                                        >arabicNames</xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <div class="row {$langClass}">
                                <div class="col-md-1 inline-h4">
                                    <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                                </div>
                                <div class="col-md-10">
                                    <xsl:choose>
                                        <xsl:when
                                            test="@xml:lang = 'he' or contains(@xml:lang, 'he')">
                                            <xsl:value-of select="t:forename"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="t:addName[@type = 'patronym']"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="t:addName[@type = 'epithet']"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="t:addName[@type = 'acronym']"/>
                                            <xsl:if
                                                test="t:addName[@type = 'shuhra'][string-length(normalize-space(.)) gt 2]">
                                                <br/>
                                                <xsl:text>(</xsl:text>
                                                <i>
                                                  <xsl:text>known as </xsl:text>
                                                </i>
                                                <xsl:value-of select="t:addName[@type = 'shuhra']"/>
                                                <xsl:text>)</xsl:text>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when
                                            test="@xml:lang = 'ar' or contains(@xml:lang, 'ar')">
                                            <xsl:value-of select="t:addName[@type = 'kunya']"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="t:addName[@type = 'ism']"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of
                                                select="replace(t:addName[@type = 'nasab'], 'ابن', 'بن')"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="t:addName[@type = 'nisbah']"/>
                                            <xsl:if
                                                test="t:addName[@type = 'laqab'][string-length(normalize-space(.)) gt 2]">
                                                <xsl:text>, </xsl:text>
                                                <xsl:value-of select="t:addName[@type = 'laqab']"/>
                                            </xsl:if>
                                            <xsl:if
                                                test="t:addName[@type = 'shuhra'][string-length(normalize-space(.)) gt 2]">
                                                <br/>
                                                <xsl:text>(</xsl:text>
                                                <i>
                                                  <xsl:text>known as </xsl:text>
                                                </i>
                                                <xsl:value-of select="t:addName[@type = 'shuhra']"/>
                                                <xsl:text>)</xsl:text>
                                            </xsl:if>
                                        </xsl:when>
                                    </xsl:choose>
                                </div>
                            </div>
                        </xsl:for-each>
                        <xsl:for-each
                            select="t:persName[@type = 'majlis-headword'][string-length(normalize-space(.)) gt 2]">
                            <xsl:variable name="langClass">
                                <xsl:choose>
                                    <xsl:when test="contains(@xml:lang, 'Latn') or @xml:lang = 'en'"
                                        >englishNames</xsl:when>
                                    <xsl:when
                                        test="@xml:lang = 'he' or contains(@xml:lang, 'he') or contains(@xml:lang, 'Hebr')"
                                        >hebrewNames</xsl:when>
                                    <xsl:when
                                        test="@xml:lang = 'ar' or contains(@xml:lang, 'ar') or contains(@xml:lang, 'Arab')"
                                        >arabicNames</xsl:when>
                                </xsl:choose>
                            </xsl:variable>
                            <div class="row {$langClass}">
                                <div class="col-md-1 inline-h4">
                                    <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                                </div>
                                <div class="col-md-10">
                                    <xsl:apply-templates select="."/>
                                </div>
                            </div>
                        </xsl:for-each>
                    </div>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:person" mode="attestedNames">
        <xsl:if test="t:persName[@type = 'attested']">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuAttestedNames"
                        >Attested Names</a>
                </h3>
                <div class="collapse" id="mainMenuAttestedNames">
                    <xsl:for-each
                        select="t:persName[@type = 'attested'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:choose>
                                    <xsl:when test="@xml:lang[. != '']">
                                        <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Name </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="t:name"/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:person" mode="biography">
        <xsl:if
            test="t:note | t:birth | t:death | t:floruit | t:sex | t:faith | t:occupation | t:residence">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuBiography"
                        >Biography</a>
                </h3>
                <div class="collapse" id="mainMenuBiography">
                    <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Description </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                                <xsl:choose>
                                    <xsl:when test="@resp = 'gschwarb'">
                                        <xsl:text>(By Gregor Schwarb)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@resp = 'rvollandt'">
                                        <xsl:text>(By Ronny Vollandt)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@resp = 'ptarras'">
                                        <xsl:text>(By Peter Tarras)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@resp = 'nurbiczek'">
                                        <xsl:text>(By Nadine Urbiczek)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:birth/t:date[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Date of birth </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each
                        select="t:birth/t:placeName[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Place of birth </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:death/t:date[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Date of death </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each
                        select="t:death/t:placeName[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Place of death </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:floruit/t:date[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Date of activity </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each
                        select="t:floruit/t:placeName[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Place of activity </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:sex[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Sex </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:faith[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Faith </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:occupation[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Occupation </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each
                        select="t:residence/t:placeName[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Place of residence </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:person" mode="person-bibliography">
        <xsl:if test="t:bibl[string-length(normalize-space(.)) gt 2][@type = 'bibliography']">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuBibliography"
                        >Bibliography</a>
                </h3>
                <div class="collapse" id="mainMenuBibliography">
                    <xsl:for-each
                        select="t:bibl[string-length(normalize-space(.)) gt 2][@type = 'bibliography']">
                        <div class="row">
                            <xsl:if test="@xml:id != ''">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="@xml:id"/>
                                </xsl:attribute>
                            </xsl:if>
                            <!--<div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>-->
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                                <!--
                                <xsl:choose>
                                    <xsl:when test="t:bibl/t:ptr[starts-with(@target, 'https://jalit.org/')]">
                                        <xsl:apply-templates select="." mode="majlisCite"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                -->
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:person" mode="person-attestations">
        <xsl:if test="t:bibl[@type = 'manuscript']">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuAttestations"
                        >Attestations</a>
                </h3>
                <div class="collapse" id="mainMenuAttestations">
                    <xsl:for-each
                        select="t:bibl[string-length(normalize-space(.)) gt 2][@type = 'manuscript']">
                        <div class="row">
                            <xsl:if test="@xml:id != ''">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="@xml:id"/>
                                </xsl:attribute>
                            </xsl:if>
                            <!--<div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>-->
                            <div class="col-md-10">
                                <xsl:apply-templates mode="majlisCite" select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:person" mode="linkedOpenData">
        <xsl:if test="t:idno[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuLinkedOpenData"
                        >Linked Open Data</a>
                </h3>
                <div class="collapse" id="mainMenuLinkedOpenData">
                    <xsl:for-each select="t:idno[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="upper-case(@subtype)"/>
                            </div>
                            <div class="col-md-10">
                                <a target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                    <xsl:value-of select="tokenize(., '/')[last()]"/>
                                </a>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:place" mode="place-names">
        <xsl:if test="t:placeName">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuNames">Names</a>
                </h3>
                <div class="collapse" id="mainMenuNames">
                    <xsl:for-each select="t:placeName[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:place" mode="place-location">
        <xsl:if
            test="t:desc/t:quote | t:location/t:geo | t:location/t:settlement | t:location/t:region">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuLocation"
                        >Location</a>
                </h3>
                <div class="collapse" id="mainMenuLocation">
                    <xsl:for-each select="t:desc/t:quote[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Description </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:location/t:geo[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Coordinates </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each
                        select="t:location/t:settlement[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">City </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each
                        select="t:location/t:region[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Region </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:place" mode="place-linkedOpenData">
        <xsl:if test="t:idno[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuLinkedOpenData"
                        >Linked Open Data</a>
                </h3>
                <div class="collapse" id="mainMenuLinkedOpenData">
                    <xsl:for-each select="t:idno[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:choose>
                                    <xsl:when test="contains(., 'viaf')">
                                        <xsl:text>VIAF</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(., 'gnd')">
                                        <xsl:text>GND</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(., 'geonames')">
                                        <xsl:text>Geonames</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(., 'wikidata')">
                                        <xsl:text>Wikidata</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(., 'loc')">
                                        <xsl:text>LOC</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(., 'bnf')">
                                        <xsl:text>BNF</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                            </div>
                            <div class="col-md-10">
                                <a target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                    <xsl:value-of select="tokenize(., '/')[last()]"/>
                                </a>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- majlis-works -->
    <xsl:template match="*:works" mode="relatedWorks">
        <xsl:if test="descendant::t:title[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuRelatedWorks"
                        >Works</a>
                </h3>
                <div class="collapse" id="mainMenuRelatedWorks">
                    <xsl:for-each select="descendant::t:body/t:bibl">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Title </div>
                            <div class="col-md-10">
                                <xsl:choose>
                                    <xsl:when
                                        test="t:title[@type = 'majlis-headword'][@xml:lang != 'en'][. != '']">
                                        <a
                                            href="{concat($nav-base,substring-after(ancestor::t:TEI/descendant::t:publicationStmt/t:idno[@type='URI'][1], $base-uri))}">
                                            <xsl:apply-templates
                                                select="t:title[@type = 'majlis-headword'][@xml:lang != 'en']"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:if
                                                test="t:title[@type = 'majlis-headword'][@xml:lang = 'en']"
                                                > [<xsl:apply-templates
                                                  select="t:title[@type = 'majlis-headword'][@xml:lang = 'en']"
                                                />]<xsl:text> </xsl:text>
                                            </xsl:if>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="t:title">
                                            <a
                                                href="{concat($nav-base,substring-after(ancestor::t:TEI/descendant::t:publicationStmt/t:idno[@type='URI'][1], $base-uri))}">
                                                <xsl:apply-templates/>
                                            </a>
                                            <xsl:text> </xsl:text>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="work-title">
        <xsl:if test="t:title[@type != 'attested'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuTitle">Title</a>
                </h3>
                <div class="collapse" id="mainMenuTitle">
                    <xsl:for-each
                        select="t:title[@type != 'attested'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Title <xsl:if
                                    test="./@xml:lang[. != '']"> (<xsl:value-of
                                        select="local:expand-lang(./@xml:lang, '')"/>) </xsl:if>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="work-attestedTitles">
        <xsl:if test="t:title[@type = 'attested'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuAttestedTitles"
                        >Attested Titles</a>
                </h3>
                <div class="collapse" id="mainMenuAttestedTitles">
                    <xsl:for-each
                        select="t:title[@type = 'attested'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Title <xsl:if
                                    test="./@xml:lang[. != '']"> (<xsl:value-of
                                        select="local:expand-lang(./@xml:lang, '')"/>) </xsl:if>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="work-content">
        <xsl:if
            test="t:incipit[string-length(normalize-space(.)) gt 2] | t:explicit[string-length(normalize-space(.)) gt 2] | t:quote[string-length(normalize-space(.)) gt 2] | t:note[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse"
                        href="#mainMenuContentInformation">Content Information</a>
                </h3>
                <div class="collapse" id="mainMenuContentInformation">
                    <xsl:for-each select="t:incipit[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Incipit </div>
                            <div class="col-md-10">
                                <xsl:value-of select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:explicit[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Explicit </div>
                            <div class="col-md-10">
                                <xsl:value-of select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:quote[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Chapter heading </div>
                            <div class="col-md-10">
                                <xsl:value-of select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">Description </div>
                            <div class="col-md-10">
                                <xsl:value-of select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="work-translations">
        <xsl:if test="t:bibl[@type = 'translated'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuTranslations"
                        >Translations</a>
                </h3>
                <div class="collapse" id="mainMenuTranslations">
                    <xsl:for-each
                        select="t:bibl[@type = 'translated'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates mode="majlisCite" select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="work-bibliography">
        <xsl:if test="t:bibl[@type != 'translated'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuBibliography"
                        >Bibliography</a>
                </h3>
                <div class="collapse" id="mainMenuBibliography">
                    <xsl:for-each
                        select="t:bibl[@type != 'translated'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates mode="majlisCite" select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:place" mode="place-bibliography">
        <xsl:if test="t:bibl[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" data-toggle="collapse" href="#mainMenuBibliography"
                        >Bibliography</a>
                </h3>
                <div class="collapse" id="mainMenuBibliography">
                    <xsl:for-each select="t:bibl[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates mode="majlisCite" select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="t:list[string-length(normalize-space(.)) gt 2]" mode="heritageData">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuHeritageData">Heritage
                    Data</a>
            </h3>
            <div class="collapse" id="mainMenuHeritageData">
                <xsl:for-each select="t:item[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">
                            <xsl:value-of select="position()"/>
                        </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Note </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Author </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:quote[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Transcription </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:bibl[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Reference </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates mode="majlisCite" select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:objectDesc" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuCodicology"
                    >Codicology</a>
            </h3>
            <div class="collapse" id="mainMenuCodicology">
                <xsl:if test="@form">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Form </div>
                        <div class="col-md-10">
                            <xsl:value-of select="@form"/>
                        </div>
                    </div>
                </xsl:if>
                <xsl:for-each
                    select="parent::t:physDesc/t:ab/t:objectType[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4"> Manuscript type </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                    <xsl:if test="@rend[. != '']">
                        <div class="row">
                            <div class="col-md-2 inline-h4"> Format </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="@rend"/>
                            </div>
                        </div>
                    </xsl:if>
                    <xsl:if test="@style[. != '']">
                        <div class="row">
                            <div class="col-md-2 inline-h4"> Book form </div>
                            <div class="col-md-10">
                                <xsl:value-of
                                    select="concat(upper-case(substring(@style, 1, 1)), substring(@style, 2))"
                                />
                            </div>
                        </div>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if
                    test="parent::t:physDesc/t:ab/t:listBibl/t:bibl[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4"> Manuscript join </div>
                        <div class="col-md-10">
                            <xsl:for-each select="parent::t:physDesc/t:ab/t:listBibl/t:bibl">
                                <p>
                                    <xsl:choose>
                                        <xsl:when test="t:ptr/@target">
                                            <xsl:variable name="link">
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="starts-with(t:ptr/@target, $base-uri)">
                                                  <xsl:value-of
                                                  select="replace(t:ptr/@target, $base-uri, $nav-base)"
                                                  />
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="t:ptr/@target"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <a href="{$link}">
                                                <xsl:value-of select="t:idno"/>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="t:idno"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when
                                            test="t:citedRange[contains(., '-')] or t:citedRange[contains(., '–')]">
                                            <xsl:text> ff. </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text> f. </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:value-of select="t:citedRange"/>
                                </p>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:if>
                <xsl:for-each
                    select="t:supportDesc/t:support/t:material[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Material </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:support/t:note[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Note </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:extent/t:measure[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Extent </div>
                        <div class="col-md-10">
                            <xsl:choose>
                                <xsl:when test=".[contains(., '-')] or .[contains(., '–')]">
                                    <xsl:text> ff. </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text> f. </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:extent/t:dimensions[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Dimensions <xsl:if test="@type != ''"
                                    >(<xsl:value-of select="@type"/>)</xsl:if>
                        </div>
                        <div class="col-md-10">
                            <xsl:call-template name="dimensions"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:if test="t:supportDesc/t:foliation[string-length(normalize-space(.)) gt 2]">
                    <xsl:variable name="label" select="local-name(.)"/>
                    <div class="row">
                        <div class="col-md-2 inline-h4">Foliation </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:supportDesc/t:foliation">
                                <xsl:if test="@rendition[. != '']">
                                    <xsl:value-of
                                        select="concat(upper-case(substring(@rendition, 1, 1)), substring(@rendition, 2))"/>
                                    <xsl:text> foliation. </xsl:text>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test=".[contains(., '-')] or .[contains(., '–')]">
                                        <xsl:text> ff. </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text> f. </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:if>
                <xsl:for-each
                    select="t:supportDesc/t:collation[string-length(normalize-space(.)) gt 2]">
                    <xsl:variable name="label" select="local-name(.)"/>
                    <div class="row">
                        <div class="col-md-2 inline-h4">
                            <xsl:value-of
                                select="concat(upper-case(substring($label, 1, 1)), substring($label, 2))"
                            />
                        </div>
                        <div class="col-md-10">
                            <xsl:value-of select="t:formula"/>
                            <xsl:text> folios per quire. </xsl:text>
                            <xsl:for-each select="t:catchwords">
                                <xsl:value-of select="."/>
                                <xsl:text>. </xsl:text>
                            </xsl:for-each>
                            <xsl:apply-templates select="t:note"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:condition/t:note[string-length(normalize-space(.)) gt 2]">
                    <xsl:variable name="label" select="local-name(.)"/>
                    <div class="row">
                        <div class="col-md-2 inline-h4">
                            <xsl:value-of
                                select="concat(upper-case(substring($label, 1, 1)), substring($label, 2))"
                            />
                        </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:condition/t:ab[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">State of writing </div>
                        <div class="col-md-10">
                            <xsl:value-of select="@rend"/>
                            <xsl:text>. </xsl:text>
                            <xsl:value-of select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:physDesc/t:objectDesc/t:layoutDesc/t:summary[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Layout summary </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="t:desc"/>
                            <xsl:text>. </xsl:text>
                            <xsl:apply-templates select="t:note"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each select="t:layoutDesc/t:layout/t:locus[@from != '' or @to != '']">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Folio range of layout</div>
                        <div class="col-md-10">
                            <xsl:call-template name="locus"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each select="t:layoutDesc/t:layout[@writtenLines != '']/@writtenLines">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Written lines</div>
                        <div class="col-md-10">
                            <xsl:choose>
                                <xsl:when test="@writtenLines[contains(., ' ')]">
                                    <xsl:value-of select="substring-before(., ' ')"/>
                                    <xsl:text> to </xsl:text>
                                    <xsl:value-of select="substring-after(., ' ')"/>
                                    <xsl:text> lines. </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                    <xsl:text> lines. </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each select="t:layoutDesc/t:layout[@columns != '']/@columns">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Columns</div>
                        <div class="col-md-10">
                            <xsl:value-of select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:layoutDesc/t:layout/t:dimensions[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Text block </div>
                        <div class="col-md-10">
                            <xsl:call-template name="dimensions"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:if
                    test="t:layoutDesc/t:layout/t:metamark[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Line justification </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:layoutDesc/t:layout/t:metamark">
                                <xsl:apply-templates select="."/>
                                <xsl:text>. </xsl:text>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:if>
                <xsl:if
                    test="t:layoutDesc/t:layout/t:ab[@type = 'ruling'][string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Ruling </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:layoutDesc/t:layout/t:ab[@type = 'ruling']">
                                <xsl:apply-templates select="."/>
                                <xsl:text>. </xsl:text>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:if>
                <xsl:if
                    test="t:layoutDesc/t:layout/t:ab[@type = 'pricking'][string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Pricking </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:layoutDesc/t:layout/t:ab[@type = 'pricking']">
                                <xsl:apply-templates select="."/>
                                <xsl:text>. </xsl:text>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:if>
                <xsl:for-each
                    select="../t:physDesc/t:decoDesc[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Page layout</div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:handDesc" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuPaleography"
                    >Paleography</a>
            </h3>
            <div class="collapse" id="mainMenuPaleography">
                <xsl:if test="t:summary[. != '']">
                    <div class="row">
                        <div class="col-md-1 inline-h4">Summary</div>
                        <div class="col-md-10">
                            <xsl:apply-templates/>
                        </div>
                    </div>
                </xsl:if>
                <xsl:for-each select="../t:scriptDesc/t:scriptNote[@script != '']">
                    <!-- <scriptNote xml:lang="arabic" script="naskh" style="" rend="calligraphic"> -->
                    <div class="row">
                        <div class="col-md-1 inline-h4">Script</div>
                        <div class="col-md-10">
                            <xsl:if test="@xml:lang != ''">
                                <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:value-of select="@script"/>
                            <xsl:text>, </xsl:text>
                            <xsl:if test="@style != ''">
                                <xsl:value-of select="@style"/>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:if test="@rend != ''">
                                <xsl:value-of select="@rend"/>
                            </xsl:if>
                            <xsl:apply-templates select="t:note"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each select="t:handNote[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">Hand <xsl:value-of select="position()"/>
                        </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:locus[@from != '' or @to != '']">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Range of hand </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Scribe </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:placeName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Place of origin </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:origDate[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Date of origin </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:if test="@script[. != ''] | @mode[. != ''] | @quality[. != '']">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Script </div>
                                    <div class="col-md-10">
                                        <xsl:value-of select="@script | @mode | @quality"/>
                                    </div>
                                </div>
                            </xsl:if>
                            <xsl:if test="@medium[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Ink </div>
                                    <div class="col-md-10">
                                        <xsl:value-of select="@medium"/>
                                    </div>
                                </div>
                            </xsl:if>
                            <xsl:for-each
                                select="t:metamark[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4"/>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4"/>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:additions" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuAdditions">Incodicated
                    Documents</a>
            </h3>
            <div class="collapse" id="mainMenuAdditions">
                <xsl:for-each select="t:list/t:item[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">
                            <xsl:value-of select="position()"/>
                        </div>
                        <div class="col-md-10">
                            <xsl:value-of select="t:objectType"/>
                            <xsl:text>, </xsl:text>
                            <xsl:choose>
                                <xsl:when test="t:locus/@from and t:locus/@to">
                                    <xsl:text>ff. </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>f. </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="t:locus/@from"/>
                            <xsl:if test="t:locus/@to != ''"> - <xsl:value-of select="t:locus/@to"/>
                            </xsl:if>
                            <xsl:for-each select="t:quote[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Transcription </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:ab[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Translation </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Person mentioned </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:placeName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Place mentioned </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Note </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:history" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuHistory">History</a>
            </h3>
            <div class="collapse" id="mainMenuHistory">
                <xsl:for-each select="t:summary[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">Summary </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each select="t:provenance[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">Provenance <xsl:value-of select="position()"
                            />
                        </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:date[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Date </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:placeName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Place </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:locus[@from != '' or @to != '']">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Range of folios </div>
                                    <div class="col-md-10">
                                        <xsl:call-template name="locus"/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Owner </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:quote[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Transcription </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:stamp[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Stamp </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Note </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each select="t:acquisition[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">Acquisition</div>
                        <div class="col-md-10">
                            <xsl:for-each
                                select="ancestor::t:msDesc/descendant::t:altIdentifier[@type = 'bundle']/t:idno[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Bundle number </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:date[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Date </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:placeName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Place </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:locus[@from != '' or @to != '']">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Range of folios </div>
                                    <div class="col-md-10">
                                        <xsl:call-template name="locus"/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Owner </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:quote[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Transcription </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:stamp[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Stamp </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Note </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:accMat" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuHeritage">Heritage
                    Data</a>
            </h3>
            <div class="collapse" id="mainMenuHeritage">
                <xsl:for-each select="t:list/t:item[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">
                            <xsl:value-of select="position()"/>
                        </div>
                        <div class="col-md-10">
                            <xsl:for-each select="t:note[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Note </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Author </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:quote[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Transcription </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                            <xsl:for-each select="t:bibl[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Reference </div>
                                    <div class="col-md-10">
                                        <xsl:apply-templates mode="majlisCite" select="."/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <!--WS:Note Adjust ListBibl majlisAdditional -->
    <xsl:template match="t:additional" mode="majlisAdditional">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuBibliography"
                    >Bibliography</a>
            </h3>
            <div class="collapse" id="mainMenuBibliography">
                <xsl:for-each select="descendant-or-self::t:listBibl">
                    <div class="row">
                        <div class="col-md-12 inline-h4">
                            <xsl:choose>
                                <xsl:when test="parent::t:surrogates">
                                    <h4>Reproductions</h4>
                                </xsl:when>
                                <xsl:otherwise>
                                    <h4>General bibliography</h4>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                    <xsl:for-each select="t:bibl[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates mode="majlisCite" select="."/>
                            </div>
                        </div>
                    </xsl:for-each>
                </xsl:for-each>
                <!-- 
/TEI/text/body/listBibl/additional/listBibl/bibl        -->
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:titleStmt" mode="majlis-credits">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" data-toggle="collapse" href="#mainMenuCredits">Credits</a>
            </h3>
            <div class="collapse" id="mainMenuCredits">
                <div class="row">
                    <div class="col-md-2 inline-h4">Project: </div>
                    <div class="col-md-10">
                        <xsl:apply-templates select="t:title[@level = 'm'][1]"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4"/>
                    <div class="col-md-10">
                        <xsl:apply-templates select="../t:editionStmt/t:edition[1]"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4">Principal investigator: </div>
                    <div class="col-md-10">
                        <xsl:for-each select="t:editor[@role = 'general']">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4">Associate researcher: </div>
                    <div class="col-md-10">
                        <xsl:for-each select="t:editor[@role = 'contributor']">
                            <xsl:apply-templates select="normalize-space(.)"/>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4">Funded through: </div>
                    <div class="col-md-10">
                        <xsl:for-each select="t:funder">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </div>
                </div>
                <xsl:for-each
                    select="ancestor::t:teiHeader/descendant::t:change[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4"> Change log:</div>
                        <div class="col-md-10">
                            <xsl:variable name="who" select="replace(@who, '#', '')"/>
                            <xsl:variable name="when">
                                <xsl:variable name="date" select="substring(@when, 1, 10)"/>
                                <xsl:choose>
                                    <xsl:when test="$date castable as xs:date">
                                        <xsl:value-of
                                            select="format-date(xs:date($date), '[D] [MNn] [Y]', 'en', (), ())"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$date"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="name">
                                <xsl:choose>
                                    <xsl:when test="descendant::t:editor[@xml:id[. = $who]]">
                                        <xsl:for-each
                                            select="descendant::t:editor[@xml:id[. = $who]][1]">
                                            <xsl:choose>
                                                <xsl:when test="t:persName">
                                                  <xsl:value-of select="t:persName"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="string-join(descendant-or-self::text(), ' ')"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$who"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:value-of select="$name"/>
                            <xsl:if test="@when[. != '']"> (<xsl:value-of select="$when"/>)</xsl:if>
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="."/>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
        <div class="whiteBoxwShadow panel panel-default">
            <div class="citationPanel">
                <h4>
                    <span class="glyphicon glyphicon-book"/> Suggested Citation </h4>
                <p class="citation">
                    <xsl:apply-templates
                        select="ancestor-or-self::t:TEI/descendant::t:teiHeader/t:fileDesc/t:titleStmt/t:title[1]"/>
                    <xsl:text>. In Digital Handbook of Jewish Authors Writing in Arabic, edited by </xsl:text>
                    <xsl:for-each
                        select="ancestor-or-self::t:TEI/descendant::t:titleStmt/t:editor[@role = 'general']">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="position() != last()"> and </xsl:if>
                    </xsl:for-each>
                    <xsl:text> et. al. Accessed </xsl:text>
                    <xsl:value-of
                        select="format-date(current-date(),&#34;[D] [MNn] [Y]&#34;, &#34;en&#34;, (), ())"/>
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates
                        select="ancestor-or-self::t:TEI/descendant::t:teiHeader/t:fileDesc/t:publicationStmt/t:idno[1]"
                    />
                </p>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:textLang">
        <xsl:for-each select="@otherLangs | @mainLang">
            <xsl:variable name="langCode" select="."/>
            <xsl:value-of select="local:expand-lang($langCode, '')"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="t:locus">
        <xsl:call-template name="locus"/>
    </xsl:template>
    <xsl:template name="locus">
        <xsl:choose>
            <xsl:when test="@to != ''">
                <xsl:text> ff. </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> f. </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="@from"/>
        <xsl:if test="@to != ''">–<xsl:value-of select="@to"/></xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="majlisCite">
        <xsl:choose>
            <xsl:when test="t:ptr/@target">
                <xsl:choose>
                    <xsl:when test="starts-with(t:ptr/@target, $base-uri)">
                        <xsl:apply-templates select="t:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{t:ptr/@target}">
                            <xsl:apply-templates select="t:title"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="t:title"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="t:citedRange[. != '']">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="majlis" select="t:citedRange"/>
    </xsl:template>
    <xsl:template match="t:citedRange" mode="majlis">
        <xsl:choose>
            <xsl:when test="@unit != ''">
                <xsl:value-of select="concat(@unit, ': ', .)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="dimensions">
        <xsl:value-of select="t:height"/>
        <xsl:value-of select="t:height/@unit"/> x <xsl:value-of select="t:width"/>
        <xsl:value-of select="t:width/@unit"/>
    </xsl:template>
    <xsl:template name="personEntities">
        <div class="collapse" id="personEntities">
            <div class="whiteBoxwShadow entityList text-left">
                <h4>Persons referenced</h4>
                <ul>
                    <xsl:for-each-group group-by="text()"
                        select="descendant::t:msDesc/descendant-or-self::t:persName[descendant-or-self::text() != ''] | descendant::t:msDesc/descendant-or-self::t:author[descendant-or-self::text() != '']">
                        <xsl:sort select="current-grouping-key()"/>
                        <li>
                            <xsl:apply-templates select="."/>
                        </li>
                    </xsl:for-each-group>
                    <!--
                    <xsl:for-each select="//t:msDesc/descendant-or-self::t:persName[descendant-or-self::text() != ''] | //t:msDesc/descendant-or-self::t:author[descendant-or-self::text() != '']">
                        <li>
                            <xsl:apply-templates select="."/>
                        </li>
                    </xsl:for-each>
                    -->
                </ul>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="placeEntities">
        <div class="collapse" id="placeEntities">
            <div class="whiteBoxwShadow entityList text-left">
                <h4>Places referenced</h4>
                <ul>
                    <xsl:for-each-group group-by="text()"
                        select="descendant::t:msDesc/descendant-or-self::t:placeName[descendant-or-self::text() != '']">
                        <xsl:sort select="current-grouping-key()"/>
                        <li>
                            <xsl:apply-templates mode="majlis" select="."/>
                        </li>
                    </xsl:for-each-group>
                </ul>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="workEntities">
        <div class="collapse" id="workEntities">
            <div class="whiteBoxwShadow entityList text-left">
                <h4>Works referenced</h4>
                <ul>
                    <xsl:for-each-group group-by="text()"
                        select="descendant::t:msDesc/descendant-or-self::t:title[not(ancestor::t:additional)][descendant-or-self::text() != '']">
                        <xsl:sort select="current-grouping-key()"/>
                        <li>
                            <xsl:apply-templates mode="majlis" select="."/>
                        </li>
                    </xsl:for-each-group>
                </ul>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:title" mode="majlis">
        <!-- <title ref="https://jalit.org/work/12">Introduction to the Commentary on the Book of Deuteronomy</title>
        concat($nav-base,substring-after(/descendant::t:idno[@type='URI'][1], $base-uri))
        -->
        <xsl:choose>
            <xsl:when test="@ref">
                <xsl:variable name="link">
                    <xsl:choose>
                        <xsl:when test="starts-with(@ref, $base-uri)">
                            <xsl:value-of select="replace(@ref, $base-uri, $nav-base)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@ref"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <a href="{$link}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
