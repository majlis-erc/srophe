<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:x="http://www.w3.org/1999/xhtml" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://syriaca.org/ns"
    exclude-result-prefixes="xs t x saxon local" version="2.0">

    <!-- ================================================================== 
       MAJLIS custom srophe XSLT
       For main record display, manuscript
       
       ================================================================== -->

    <!-- 
    <xsl:choose>
            <xsl:when test="//t:text/t:body/t:listBibl/t:msDesc">
                <xsl:apply-templates mode="majlis"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    -->

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
                <xsl:if test="//t:TEI/t:facsimile/t:graphic/@url">
                    <a type="button" class="btn btn-default btn-grey btn-sm"
                        href="{//t:TEI/t:facsimile/t:graphic/@url}" target="_blank">Scan</a>
                </xsl:if>
                <a type="button" class="btn btn-default btn-grey btn-sm" href="">Feedback</a>
                <a class="btn btn-default btn-grey btn-sm"
                    href="{concat($nav-base,substring-after(/descendant::t:idno[@type='URI'][1], $base-uri))}"
                    >XML</a>
                <a class="btn btn-default btn-grey btn-sm" href="javascript:window.print();"
                    >Print</a>
            </div>
        </div>
        <xsl:choose>
            <xsl:when test="//t:text/t:body/t:listBibl/t:msDesc">
                <xsl:apply-templates select="//t:body" mode="majlis-mss"/>
            </xsl:when>
            <xsl:when test="//t:text/t:body/t:listPerson">
                <xsl:apply-templates select="//t:body" mode="majlis-person"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="whiteBoxwShadow">
                    <xsl:apply-templates select="//t:body"/>
                    <xsl:apply-templates select="//t:teiHeader"/>
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
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </div>
                        </xsl:if>
                        <xsl:if test="t:msContents/t:msItem/t:author[. != '']">
                            <div class="item row">
                                <span class="inline-h4 col-md-3">Author</span>
                                <span class="col-md-9">
                                    <xsl:for-each select="t:msContents/t:msItem/t:author[. != '']">
                                        <xsl:apply-templates select="."/>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
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
                <button aria-expanded="true" type="button" class="btn btn-default btn-lg"
                    href="#personEntities" data-toggle="collapse">Persons</button>
                <xsl:call-template name="personEntities"/>
            </div>
            <div class="col-md-4 text-center">
                <button aria-expanded="true" type="button" class="btn btn-default btn-lg"
                    href="#placeEntities" data-toggle="collapse">Places</button>
                <xsl:call-template name="placeEntities"/>
            </div>
            <div class="col-md-4 text-right">
                <button aria-expanded="true" type="button" class="btn btn-default btn-lg"
                    href="#workEntities" data-toggle="collapse">Works</button>
                <xsl:call-template name="workEntities"/>
            </div>
        </div>
        <!-- Menu items for record contents -->
        <!-- aria-expanded="false" -->
        <xsl:variable name="Content">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:msContents" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="Codicology">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:objectDesc" mode="majlis"
            />
        </xsl:variable>
        <xsl:variable name="Paleography">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:handDesc" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="incodicatedDocuments">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:additions" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="History">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:history" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="Heritage">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:physDesc/t:accMat" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="Bibliography">
            <xsl:apply-templates select="t:listBibl/t:msDesc/t:additional/t:listBibl" mode="majlis"
            />
        </xsl:variable>
        <xsl:variable name="Credits">
            <xsl:apply-templates select="//t:teiHeader/t:fileDesc/t:titleStmt" mode="majlis-credits"
            />
        </xsl:variable>
        <div id="mainMenu">
            <div class="btn-group btn-group-justified">
                <xsl:if
                    test="$Content/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" type="button"
                            class="btn btn-default btn-grey btn-lg" href="#mainMenuContent"
                            data-toggle="collapse">Content</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Codicology/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuCodicology">Codicology</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Paleography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuPaleography" data-toggle="collapse">Paleography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$incodicatedDocuments/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuAdditions" data-toggle="collapse">Incodicated
                            Documents</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$History/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuHistory" data-toggle="collapse">History</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Heritage/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuHeritage" data-toggle="collapse">Heritage Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuBibliography" data-toggle="collapse"
                            >Bibliography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$Credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuCredits" data-toggle="collapse">Credits</button>
                    </div>
                </xsl:if>
                <div class="btn-group">
                    <button id="expand-all" type="button" class="btn btn-default btn-grey btn-lg"
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
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="canonNames">
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="attestedNames">
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="alternateNames">
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="biography">
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="heritageData">
            <xsl:apply-templates select="//t:standOff/t:list" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="bibliography">
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="linkedOpenData">
            <xsl:apply-templates select="t:listPerson/t:person" mode="majlis"/>
        </xsl:variable>
        <xsl:variable name="credits">
            <xsl:apply-templates select="//t:teiHeader/t:fileDesc/t:titleStmt" mode="majlis-credits"
            />
        </xsl:variable>
        <div id="mainMenu">
            <div class="btn-group btn-group-justified">
                <xsl:if
                    test="$majlisNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button aria-expanded="true" type="button"
                            class="btn btn-default btn-grey btn-lg" href="#mainMenuMajlisNames"
                            data-toggle="collapse">MAJLIS Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$canonNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            data-toggle="collapse" href="#mainMenuCanonNames">Canon Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$attestedNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuAttestedNames" data-toggle="collapse">Attested
                            Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$alternateNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuAlternateNames" data-toggle="collapse">Alternate
                            Names</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$biography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuBiography" data-toggle="collapse">Biography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$bibliography/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuBibliography" data-toggle="collapse"
                            >Bibliography</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$linkedOpenData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuLinkedOpenData" data-toggle="collapse">Linked Open
                            Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$heritageData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuHeritageData" data-toggle="collapse">Heritage
                            Data</button>
                    </div>
                </xsl:if>
                <xsl:if
                    test="$credits/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default btn-grey btn-lg"
                            href="#mainMenuCredits" data-toggle="collapse">Credits</button>
                    </div>
                </xsl:if>
                <div class="btn-group">
                    <button id="expand-all" type="button" class="btn btn-default btn-grey btn-lg"
                        >Open All</button>
                </div>
            </div>
            <div class="mainMenuContent">
                <!--<xsl:if
                    test="$majlisNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$majlisNames"/>
                </xsl:if>-->
                <xsl:if
                    test="$canonNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$canonNames"/>
                </xsl:if>
                <!-- <xsl:if
                    test="$attestedNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$attestedNames"/>
                </xsl:if>
                <xsl:if
                    test="$alternateNames/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$alternateNames"/>
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
                    test="$linkedOpenData/descendant::*:div[@class = 'whiteBoxwShadow']/*:div[string-length(normalize-space(string-join(descendant-or-self::text(), ''))) gt 2]">
                    <xsl:sequence select="$linkedOpenData"/>
                </xsl:if>-->
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
    <xsl:template match="t:msContents" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" href="#mainMenuContent" data-toggle="collapse">Content</a>
            </h3>
            <div class="collapse in" id="mainMenuContent">
                <xsl:for-each select="t:msItem">
                    <div class="row">
                        <div class="col-md-1">
                            <h4>Text <xsl:value-of select="position()"/></h4>
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
                                                  select="upper-case(@xml:lang)"
                                                />]</xsl:if></xsl:when>
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
                                                <xsl:apply-templates select="."/>
                                                <xsl:if
                                                  test="preceding-sibling::t:locus or following-sibling::t:locus">
                                                  <xsl:for-each
                                                  select="preceding-sibling::t:locus | following-sibling::t:locus"
                                                  > (<xsl:call-template name="locus"/>)
                                                  </xsl:for-each>
                                                </xsl:if>
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

    <xsl:template match="t:person" mode="majlis">

        <xsl:if test="t:persName[@type = 'majlis-headword']">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuMajlisNames" data-toggle="collapse"
                        >MAJLIS Names</a>
                </h3>
                <div class="collapse" id="mainMenuMajlisNames">
                    <xsl:for-each
                        select="t:persName[@type = 'majlis-headword'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="t:name"/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
        <xsl:if test="t:persName[@type = 'canon'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuCanonNames" data-toggle="collapse">Canon
                        Names</a>
                </h3>
                <div class="collapse" id="mainMenuCanonNames">
                    <xsl:for-each select="t:persName[@type = 'canon']">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:if test="t:addName[@type = 'shuhra'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Shuhra </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'shuhra'][string-length(normalize-space(.)) gt 2]"
                                            > </xsl:apply-templates>
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'ism'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Ism </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'ism'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'nasab'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Nasab </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'nasab'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'nisbah'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Nisbah </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'nisbah'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'kunya'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Kunya </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'kunya'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'laqab'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Laqab </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'laqab'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'acronym'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Acronym </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'acronym'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'patronym'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Patronym </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'patronym'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                                <xsl:if test="t:addName[@type = 'epithet'][. != '']">
                                    <div class="row">
                                        <div class="col-md-1 inline-h4">Epithet </div>
                                        <div class="col-md-10">
                                            <xsl:apply-templates
                                                select="t:addName[@type = 'epithet'][string-length(normalize-space(.)) gt 2]"
                                            />
                                        </div>
                                    </div>
                                </xsl:if>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
        <xsl:if test="t:persName[@type = 'alternate'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuAlternateNames" data-toggle="collapse"
                        >Alternate Names</a>
                </h3>
                <div class="collapse" id="mainMenuAlternateNames">
                    <xsl:for-each
                        select="t:persName[@type = 'alternate'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:choose>
                                    <xsl:when test="@xml:lang[. != '']">
                                        <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:text>Name </xsl:text></xsl:otherwise>
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
        <xsl:if test="t:persName[@type = 'attested'][string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuAttestedNames" data-toggle="collapse"
                        >Attested Names</a>
                </h3>
                <div class="collapse" id="mainMenuAttestedNames">
                    <xsl:for-each
                        select="t:persName[@type = 'attested'][string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <xsl:choose>
                                <xsl:when test="@xml:lang[. != '']">
                                    <xsl:value-of select="local:expand-lang(@xml:lang, '')"/>
                                </xsl:when>
                                <xsl:otherwise><xsl:text>Name </xsl:text></xsl:otherwise>
                            </xsl:choose>
                            <div class="col-md-10">
                                <xsl:apply-templates select="t:name"/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
        <xsl:if test="t:birth | t:death | t:floruit | t:sex | t:faith | t:occupation | t:residence">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuBiography" data-toggle="collapse"
                        >Biography</a>
                </h3>
                <div class="collapse" id="mainMenuBiography">
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
                                <xsl:value-of select="."/>
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
        <xsl:if test="t:bibl[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuBibliography" data-toggle="collapse"
                        >Bibliography</a>
                </h3>
                <div class="collapse" id="mainMenuBibliography">
                    <xsl:for-each select="t:bibl[string-length(normalize-space(.)) gt 2]">
                        <div class="row">
                            <div class="col-md-1 inline-h4">
                                <xsl:value-of select="position()"/>
                            </div>
                            <div class="col-md-10">
                                <xsl:apply-templates select="." mode="majlisCite"/>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:if>
        <xsl:if test="t:idno[string-length(normalize-space(.)) gt 2]">
            <div class="whiteBoxwShadow">
                <h3>
                    <a aria-expanded="true" href="#mainMenuLinkedOpenData" data-toggle="collapse"
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
    <xsl:template match="t:list[string-length(normalize-space(.)) gt 2]" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" href="#mainMenuHeritageData" data-toggle="collapse">Heritage
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
                                        <xsl:apply-templates select="." mode="majlisCite"/>
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
                <a aria-expanded="true" href="#mainMenuCodicology" data-toggle="collapse"
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
                                <xsl:apply-templates select="@style"/>
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
                                <p><xsl:value-of select="t:idno"/> ff. <xsl:value-of
                                        select="t:citedRange"/> [<a href="t:ptr/@target"
                                            ><xsl:value-of select="t:ptr/@target"/></a>]</p>
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
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:extent/t:dimensions[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">Dimensions <xsl:if test="@type != ''"
                                    >(<xsl:value-of select="@type"/>)</xsl:if></div>
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
                                <xsl:value-of select="@rendition"/> <xsl:apply-templates select="."
                                />
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
                            <xsl:text> per quire.  </xsl:text>
                            <xsl:value-of select="t:catchwords"/>
                            <xsl:text>.  </xsl:text>
                            <xsl:apply-templates select="t:note"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:condition[string-length(normalize-space(.)) gt 2]">
                    <xsl:variable name="label" select="local-name(.)"/>
                    <div class="row">
                        <div class="col-md-2 inline-h4">
                            <xsl:value-of
                                select="concat(upper-case(substring($label, 1, 1)), substring($label, 2))"
                            />
                        </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="t:note"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:supportDesc/t:condition[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4">State of writing </div>
                        <div class="col-md-10">
                            <xsl:value-of select="t:ab/@rend"/>
                            <xsl:text>. </xsl:text>
                            <xsl:value-of select="t:ab"/>
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
                            <xsl:value-of select="."/>
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
                        <div class="col-md-2 inline-h4">Text block</div>
                        <div class="col-md-10">
                            <xsl:call-template name="dimensions"/>
                        </div>
                    </div>
                </xsl:for-each>
                <xsl:for-each
                    select="t:layoutDesc/t:layout/t:metamark[string-length(normalize-space(.)) gt 2] | t:layoutDesc/t:layout/t:ab[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-2 inline-h4"/>
                        <div class="col-md-10">
                            <xsl:apply-templates select="."/>
                        </div>
                    </div>
                </xsl:for-each>
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
                <a aria-expanded="true" href="#mainMenuPaleography" data-toggle="collapse"
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
                <a aria-expanded="true" href="#mainMenuAdditions" data-toggle="collapse">Incodicated
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
                            <xsl:text>, ff. </xsl:text>
                            <xsl:value-of select="t:locus/@from"/>
                            <xsl:if test="t:locus/@to != ''"> - <xsl:value-of select="t:locus/@to"
                                /></xsl:if>
                            <xsl:for-each
                                select="t:persName[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Person mentioned </div>
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
                            <xsl:for-each select="t:ab[string-length(normalize-space(.)) gt 2]">
                                <div class="row">
                                    <div class="col-md-2 inline-h4">Translation </div>
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
                <a aria-expanded="true" href="#mainMenuHistory" data-toggle="collapse">History</a>
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
                            /></div>
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
                <a aria-expanded="true" href="#mainMenuHeritage" data-toggle="collapse">Heritage
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
                                        <xsl:apply-templates select="." mode="majlisCite"/>
                                    </div>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:listBibl" mode="majlis">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" href="#mainMenuBibliography" data-toggle="collapse"
                    >Bibliography</a>
            </h3>
            <div class="collapse" id="mainMenuBibliography">
                <xsl:for-each select="t:bibl[string-length(normalize-space(.)) gt 2]">
                    <div class="row">
                        <div class="col-md-1 inline-h4">
                            <xsl:value-of select="position()"/>
                        </div>
                        <div class="col-md-10">
                            <xsl:apply-templates select="." mode="majlisCite"/>
                        </div>
                    </div>
                </xsl:for-each>
                <!-- 
/TEI/text/body/listBibl/additional/listBibl/bibl        -->
            </div>
        </div>
    </xsl:template>
    <xsl:template match="t:titleStmt" mode="majlis-credits">
        <div class="whiteBoxwShadow">
            <h3>
                <a aria-expanded="true" href="#mainMenuCredits" data-toggle="collapse">Credits</a>
            </h3>
            <div class="collapse" id="mainMenuCredits">
                <div class="row">
                    <div class="col-md-2 inline-h4">Project: </div>
                    <div class="col-md-10">
                        <xsl:apply-templates select="//t:titleStmt/t:title[@level = 'm'][1]"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4"/>
                    <div class="col-md-10">
                        <xsl:apply-templates select="//t:editionStmt/t:edition[1]"/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4">Principal investigator: </div>
                    <div class="col-md-10">
                        <xsl:for-each select="//t:titleStmt/t:editor[@role = 'general']">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>

                    </div>
                </div>
                <div class="row">
                    <div class="col-md-2 inline-h4">Associate researcher: </div>
                    <div class="col-md-10">
                        <xsl:for-each select="//t:titleStmt/t:editor[@role = 'contributor']">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </div>
                </div>
                <xsl:for-each select="//t:change[string-length(normalize-space(.)) gt 2]">
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
                                    <xsl:when test="//t:editor[@xml:id[. = $who]]">
                                        <xsl:for-each select="//t:editor[@xml:id[. = $who]][1]">
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
                <h4><span class="glyphicon glyphicon-book"/> Suggested Citation </h4>
                <p class="citation">
                    <xsl:apply-templates select="//t:teiHeader/t:fileDesc/t:titleStmt/t:title[1]"/>
                    <xsl:text>. In Digital Handbook of Jewish Authors Writing in Arabic, edited by Ronny Vollandt. Accessed </xsl:text>
                    <xsl:value-of
                        select="format-date(current-date(),&#34;[D] [MNn] [Y]&#34;, &#34;en&#34;, (), ())"/>
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates
                        select="//t:teiHeader/t:fileDesc/t:publicationStmt/t:idno[1]"/>
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
        <xsl:value-of select="@from"/>
        <xsl:if test="@to != ''"> - <xsl:value-of select="@to"/></xsl:if>
    </xsl:template>
    <xsl:template match="t:bibl" mode="majlisCite">
        <xsl:if test="t:ptr/@target[. != '']">
            <a href="{t:ptr/@target}" target="_blank">
                <xsl:apply-templates select="t:title"/>
            </a>
        </xsl:if>
        <xsl:if test="t:citedRange[. != '']">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="t:citedRange" mode="majlis"/>
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
        <xsl:value-of select="t:height"/> <xsl:value-of select="t:height/@unit"/> x  <xsl:value-of
            select="t:width"/> <xsl:value-of select="t:width/@unit"/>
    </xsl:template>
    <xsl:template name="personEntities">
        <div class="collapse" id="personEntities">
            <div class="whiteBoxwShadow entityList text-left">
                <h4>Persons referenced</h4>
                <ul>
                    <xsl:for-each
                        select="//t:msDesc/descendant-or-self::t:persName[descendant-or-self::text() != ''] | //t:msDesc/descendant-or-self::t:author[descendant-or-self::text() != '']">
                        <li>
                            <xsl:apply-templates select="."/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="placeEntities">
        <div class="collapse" id="placeEntities">
            <div class="whiteBoxwShadow entityList text-left">
                <h4>Places referenced</h4>
                <ul>
                    <xsl:for-each
                        select="//t:msDesc/descendant-or-self::t:placeName[descendant-or-self::text() != '']">
                        <li>
                            <xsl:apply-templates select="." mode="majlis"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="workEntities">
        <div class="collapse" id="workEntities">
            <div class="whiteBoxwShadow entityList text-left">
                <h4>Works referenced</h4>
                <ul>
                    <xsl:for-each
                        select="//t:msDesc/descendant-or-self::t:title[not(ancestor::t:additional)][descendant-or-self::text() != '']">
                        <li>
                            <xsl:apply-templates select="." mode="majlis"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
