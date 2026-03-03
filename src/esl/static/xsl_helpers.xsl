<xsl:template name="wordwrap">
		<xsl:param name="productFieldValue"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="textVertAlign"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="textHeight"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="textLineHeight"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="currencySign"/>
		<xsl:param name="currencyPosition"/>
		<xsl:param name="currencyFormat"/>
    <xsl:param name="currencyFormatType"/>
    <xsl:param name="currencyCode"/>
    <xsl:param name="zeroformatEnabled"/>
    <xsl:param name="text_decoration_overline"/>
    <xsl:param name="text_decoration_underline"/>
    <xsl:param name="text_decoration_strikethrough"/>
    <xsl:param name="isToApplyUpperCase"/>
    <xsl:param name="isToApplyLowerCase"/>
    <xsl:param name="letterSpacing"/>
    <xsl:param name="isScalingTextFit"/>
    <xsl:param name="isScalingTextFitUpscalingAllowed"/>
    <xsl:param name="customCurrencyFormatName"/>
    <xsl:param name="customCurrencyThousandSeparator"/>
    <xsl:param name="currencySignDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalSeperatorVisible"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalPortionVisible"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
		<xsl:param name="isCustomCurrencyFormat"/>
		<xsl:param name="currencySizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalSeperatorSizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalPortionSizeRatioWithFontSize"/>
		<xsl:param name="isSplitting"/>
		<xsl:param name="splitBy"/>

    <xsl:variable name="addedSlashnForSplit">
      <xsl:choose>
        <xsl:when test="$isSplitting = 'true'">
          <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="$productFieldValue" />
            <xsl:with-param name="replace" select="$splitBy" />
            <xsl:with-param name="by" select="'\n'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$productFieldValue" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>



    <xsl:variable name="modifiedProductField">
			<xsl:call-template name="replace-backslash-n">
				<xsl:with-param name="text" select="$addedSlashnForSplit" />
				<xsl:with-param name="accum" select="''" />
			</xsl:call-template>
		</xsl:variable>

    <xsl:variable name="currencyfiedString_NL">
			<xsl:call-template name="replace-backslash-n-with-flag">
				<xsl:with-param name="text" select="$modifiedProductField"/>
				<xsl:with-param name="search" select="'U+000A'"/>
				<xsl:with-param name="replace" select="concat(' ', $FORCED_NL_TOKEN, ' ')"/>
			</xsl:call-template>
    </xsl:variable>

    <xsl:variable name="productFieldValue1">
		<xsl:choose>
			<xsl:when test="contains($currencyfiedString_NL, '1_quot_1')">
			   <xsl:value-of select='concat(substring-before($currencyfiedString_NL, "1_quot_1"),"&#39;",substring-after($currencyfiedString_NL, "1_quot_1"))'/>
			</xsl:when>
			<xsl:otherwise>
			  <xsl:value-of select="$currencyfiedString_NL"/>
			</xsl:otherwise>
		</xsl:choose>	    
  </xsl:variable>
		<xsl:variable name="commaValidation">
		  <xsl:value-of select="translate($productFieldValue1, ',', '.')"/>
		</xsl:variable>
		<xsl:variable name="newtSpanX">
			<xsl:value-of  select="$tspanX"/>
		</xsl:variable>
		<xsl:variable name="currencyfiedString">
			<xsl:choose>
			  <xsl:when test="number($productFieldValue1) = $productFieldValue1">
					<xsl:call-template name="addCurrencySign">
						<xsl:with-param name="productFieldValue" select="$commaValidation"/>
						<xsl:with-param name="currencySign" select="$currencySign"/>
						<xsl:with-param name="currencyPosition" select="$currencyPosition"/>
						<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
						<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
						<xsl:with-param name="currencyCode" select="$currencyCode"/>
						<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="number($commaValidation) = $commaValidation">
					<xsl:call-template name="addCurrencySign">
						<xsl:with-param name="productFieldValue" select="$commaValidation"/>
						<xsl:with-param name="currencySign" select="$currencySign"/>
						<xsl:with-param name="currencyPosition" select="$currencyPosition"/>
						<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
						<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
						<xsl:with-param name="currencyCode" select="$currencyCode"/>
						<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$isToApplyUpperCase = 'true'">
						  <xsl:value-of  select="translate($productFieldValue1,$smallcase,$uppercase)"/>
						</xsl:when>
						<xsl:when test="$isToApplyLowerCase = 'true'">
						  <xsl:value-of  select="translate($productFieldValue1,$uppercase,$smallcase)"/>
						</xsl:when>
						<xsl:otherwise>
						  <xsl:value-of select="$productFieldValue1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vrtfSplitWords">
      <xsl:if test="$isScalingTextFit = 'true'">
        <xsl:if test="$isScalingTextFitUpscalingAllowed = 'true'"> 
          <xsl:call-template name="getValueAsTreeElement">
            <xsl:with-param name="pText" select="$currencyfiedString"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="$isScalingTextFitUpscalingAllowed != 'true'">
          <xsl:if test="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) &lt; $textWidth)">
            <xsl:call-template name="split">
              <xsl:with-param name="pText" select="$currencyfiedString"/>
              <xsl:with-param name="delimiter" select="' '"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
            </xsl:call-template>  
          </xsl:if>
          <xsl:if test="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) &gt;= $textWidth)">
            
              <xsl:call-template name="getValueAsTreeElement">
                <xsl:with-param name="pText" select="$currencyfiedString"/>
              </xsl:call-template>
            
          </xsl:if>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$isScalingTextFit != 'true'">
        <xsl:call-template name="split">
          <xsl:with-param name="pText" select="$currencyfiedString"/>
          <xsl:with-param name="delimiter" select="' '"/>
          <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
          
        </xsl:call-template>    
      </xsl:if>
		</xsl:variable>
		<xsl:variable name="vSplitWords" select="ext:node-set($vrtfSplitWords)/*"/>
		<!--  got the first word -->
		<xsl:variable name="word">
			<xsl:value-of select="$vSplitWords[1]"/>
		</xsl:variable>
		<xsl:variable name="linesElement">
			<xsl:call-template name="wordwrap_createtspan_cal_totalTextHeight">
				<xsl:with-param name="node" select="$vSplitWords"/>
				<xsl:with-param name="position" select="1"/>
				<xsl:with-param name="word" select="($word)"/>
				<xsl:with-param name="size" select="count($vSplitWords)"/>
				<xsl:with-param name="noOfLine" select="0"/>
				<xsl:with-param name="textAnchor" select="$textAnchor"/>
				<xsl:with-param name="textWidth" select="$textWidth"/>
				<xsl:with-param name="textHeight" select="$textHeight"/>
				<xsl:with-param name="fontFamily" select="$fontFamily"/>
				<xsl:with-param name="fontStyle" select="$fontStyle"/>
				<xsl:with-param name="fontSize" select="$fontSize"/>
				<xsl:with-param name="fontWeight" select="$fontWeight"/>
				<xsl:with-param name="lineHeight" select="$lineHeight"/>
				<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
				<xsl:with-param name="tspanX" select="$newtSpanX"/>
				<xsl:with-param name="tspanY" select="$tspanY"/>
				<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
				<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
				<xsl:with-param name="currencySign" select="$currencySign"/>
				<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="linesArray" select="ext:node-set($linesElement)/*"/>
    <xsl:variable name="verticalAlignOffset">
      <xsl:if test="$textVertAlign = 'middle'">
        <xsl:value-of select="(($textHeight - ($lineHeight * count($linesArray))) div 2) + (($lineHeight - $textLineHeight) div 2) - (($textHeight - ($lineHeight * 1)) div 2)"/>
      </xsl:if>
      <xsl:if test="$textVertAlign = 'bottom'">
        <xsl:value-of select="(($textHeight - $lineHeight * count($linesArray))) + (($lineHeight - $textLineHeight) div 2) - ($textHeight - ($lineHeight * 1))"/>
      </xsl:if>
      <xsl:if test="$textVertAlign = 'top'">
        <xsl:value-of select="0"/>
      </xsl:if>
    </xsl:variable>
		<xsl:call-template name="wordwrap_createtspan">
			<xsl:with-param name="node" select="$vSplitWords"/>
			<xsl:with-param name="position" select="1"/>
			<xsl:with-param name="word" select="($word)"/>
			<xsl:with-param name="size" select="count($vSplitWords)"/>
			<xsl:with-param name="noOfLine" select="0"/>
			<xsl:with-param name="textAnchor" select="$textAnchor"/>
			<xsl:with-param name="textWidth" select="$textWidth"/>
			<xsl:with-param name="textHeight" select="$textHeight"/>
			<xsl:with-param name="fontFamily" select="$fontFamily"/>
			<xsl:with-param name="fontStyle" select="$fontStyle"/>
			<xsl:with-param name="fontSize" select="$fontSize"/>
			<xsl:with-param name="fontWeight" select="$fontWeight"/>
			<xsl:with-param name="lineHeight" select="$lineHeight"/>
			<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
			<xsl:with-param name="tspanX" select="$newtSpanX"/>
			<xsl:with-param name="tspanY" select="$tspanY"/>
			<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
			<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
			<xsl:with-param name="currencySign" select="$currencySign"/>
			<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
			<xsl:with-param name="totalLines" select="count($linesArray)"/>
      <xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
      <xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>      
      <xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>      
      <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>    
      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>  
      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
      <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
      <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>
      <xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"></xsl:with-param>
      <xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"></xsl:with-param>
      <xsl:with-param name="currencyPosition" select="$currencyPosition"></xsl:with-param>
			<xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"></xsl:with-param>
			<xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"></xsl:with-param>
			<xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"></xsl:with-param>
			<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"></xsl:with-param>
			<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"></xsl:with-param>
			<xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"></xsl:with-param>
			<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"></xsl:with-param>
			<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"></xsl:with-param>
			<xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"></xsl:with-param>
			<xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"></xsl:with-param>
			<xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"></xsl:with-param>
			<xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"></xsl:with-param>


		</xsl:call-template>
	</xsl:template><xsl:template name="wordwrap_createtspan_cal_totalTextHeight">
		<xsl:param name="node"/>
		<xsl:param name="position"/>
		<xsl:param name="prevWord"/>
		<xsl:param name="word"/>
		<xsl:param name="size"/>
		<xsl:param name="noOfLine"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="textHeight"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="textLineHeight"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="currencyFormat"/>
		<xsl:param name="currencyFormatType"/>
		<xsl:param name="currencyfiedString"/>
		<xsl:param name="currencySign"/>
    <xsl:param name="letterSpacing"/>
    <xsl:param name="currencyPosition"/>
    <xsl:param name="customCurrencyFormatName"/>
    <xsl:param name="customCurrencyThousandSeparator"/>     
		<xsl:param name="currencySignDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalSeperatorVisible"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalPortionVisible"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
		<xsl:param name="isCustomCurrencyFormat"/>
		<xsl:param name="currencySizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalSeperatorSizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalPortionSizeRatioWithFontSize"/>

		<xsl:choose>
        <xsl:when test="$node[$position] = $FORCED_NL_TOKEN">
            <!-- Flush current line if it has content -->
			      <xsl:if test="string-length(normalize-space($prevWord)) &gt; 0">
					      <xsl:element name="line">
					         <xsl:value-of select="$prevWord"/>
				        </xsl:element>
			      </xsl:if>
			     <!-- Always add a line marker, even if empty -->
			      <xsl:element name="line">
				      <xsl:text></xsl:text>
			      </xsl:element>

			      <!-- Continue recursion after the token -->
            <xsl:if test="$size &gt; 1">
              <xsl:call-template name="wordwrap_createtspan_cal_totalTextHeight">
              <xsl:with-param name="node" select="$node"/>
              <xsl:with-param name="position" select="$position + 1"/>
              <xsl:with-param name="prevWord" select="''"/>
              <xsl:with-param name="word" select="$node[$position + 1]"/>
              <xsl:with-param name="size" select="$size - 1"/>
              <xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
              <xsl:with-param name="textAnchor" select="$textAnchor"/>
              <xsl:with-param name="textWidth" select="$textWidth"/>
              <xsl:with-param name="textHeight" select="$textHeight"/>
              <xsl:with-param name="lineHeight" select="$lineHeight"/>
              <xsl:with-param name="textLineHeight" select="$textLineHeight"/>
              <xsl:with-param name="tspanX" select="$tspanX"/>
              <xsl:with-param name="tspanY" select="$tspanY"/>
              <xsl:with-param name="fontStyle" select="$fontStyle"/>
              <xsl:with-param name="fontFamily" select="$fontFamily"/>
              <xsl:with-param name="fontWeight" select="$fontWeight"/>
              <xsl:with-param name="fontSize" select="$fontSize"/>
              <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
              <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
              <xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
              <xsl:with-param name="currencySign" select="$currencySign"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
              <xsl:with-param name="currencyPosition" select="$currencyPosition"/>
              <xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"/>
              <xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"/>
              <xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"/>
              <xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"/>
              <xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"/>
              <xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
              <xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
              <xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"/>
              <xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
              <xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
              <xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"/>
              <xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"/>
              <xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"/>
              <xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"/>
              </xsl:call-template>
            </xsl:if>
        </xsl:when>

			<xsl:when test="dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily , $fontWeight , $fontStyle, $fontSize) >= $textWidth and $size > 1">
				<xsl:choose>
					<!-- check if prevword can only accomodate since current word has greater width -->
					<xsl:when test="(dgext:getTextWidth(concat('',$letterSpacing,''),$prevWord, $fontFamily , $fontWeight , $fontStyle, $fontSize) &gt; 0) and (dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily , $fontWeight , $fontStyle, $fontSize) > $textWidth) and (dgext:getTextWidth(concat('',$letterSpacing,''),$prevWord, $fontFamily , $fontWeight , $fontStyle, $fontSize) &lt; $textWidth)">
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
							<xsl:element name="line">
								<xsl:value-of select="$prevWord"/>
							</xsl:element>
							<!-- <xsl:element name="svg:tspan"><xsl:attribute name="text-anchor"><xsl:value-of select="$textAnchor"/></xsl:attribute><xsl:attribute name="x"><xsl:value-of select="$tspanX"/></xsl:attribute><xsl:attribute name="y"><xsl:value-of select="$lineHeight * $noOfLine + $tspanY"/></xsl:attribute><xsl:value-of select="$prevWord"/></xsl:element> -->
						</xsl:if>
						<xsl:choose>
							<xsl:when test="count($node) > $position">
								<xsl:call-template name="wordwrap_createtspan_cal_totalTextHeight">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="position" select="$position+1"/>
									<xsl:with-param name="prevWord" select="$node[$position]"></xsl:with-param>
									<xsl:with-param name="word" select="(concat($node[$position],' ',$node[$position+1]))"/>
									<xsl:with-param name="size" select="$size - 1"/>
									<xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
									<xsl:with-param name="textAnchor" select="$textAnchor"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
									<xsl:with-param name="textHeight" select="$textHeight"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="lineHeight" select="$lineHeight"/>
									<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
									<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
									<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
									<xsl:with-param name="currencySign" select="$currencySign"/>
									<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									<xsl:with-param name="tspanX" select="$tspanX"/>
									<xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="wordwrap_createtspan_cal_totalTextHeight">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="position" select="$position"/>
									<xsl:with-param name="prevWord" select="$node[$position]"></xsl:with-param>
									<xsl:with-param name="word" select="($node[$position])"/>
									<xsl:with-param name="size" select="$size"/>
									<xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
									<xsl:with-param name="textAnchor" select="$textAnchor"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
									<xsl:with-param name="textHeight" select="$textHeight"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="lineHeight" select="$lineHeight"/>
									<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									<xsl:with-param name="tspanX" select="$tspanX"/>
									<xsl:with-param name="tspanY" select="$tspanY"/>
									<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
									<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
									<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
									<xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight)">
							<xsl:variable name="finalWord" >
								<xsl:call-template name="slice_text">
									<xsl:with-param name="textField" select="$word"/>
									<xsl:with-param name="position" select="0"/>
									<xsl:with-param name="finalText" select="''"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

								</xsl:call-template>
							</xsl:variable>
							<xsl:element name="line">
								<xsl:value-of select="$prevWord"/>
							</xsl:element>
							<!-- <xsl:element name="svg:tspan"><xsl:attribute name="text-anchor"><xsl:value-of select="$textAnchor"/></xsl:attribute><xsl:attribute name="x"><xsl:value-of select="$tspanX"/></xsl:attribute><xsl:attribute name="y"><xsl:value-of select="$lineHeight * $noOfLine + $tspanY"/></xsl:attribute><xsl:value-of select="$finalWord"/></xsl:element> -->
						</xsl:if>
						<xsl:call-template name="wordwrap_createtspan_cal_totalTextHeight">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="position" select="$position + 1"/>
							<xsl:with-param name="word" select="($node[$position+1])"/>
							<xsl:with-param name="size" select="$size - 1"/>
							<xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="textHeight" select="$textHeight"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="lineHeight" select="$lineHeight"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
							<xsl:with-param name="textAnchor" select="$textAnchor"/>
							<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
							<xsl:with-param name="currencySign" select="$currencySign"/>
							<xsl:with-param name="tspanX" select="$tspanX"/>
							<xsl:with-param name="tspanY" select="$tspanY"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$size = 1 and ($textWidth >= dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily , $fontWeight , $fontStyle, $fontSize))  and $currencyFormatType = '' and (not($isCustomCurrencyFormat = 'true'))">
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
							<xsl:element name="line">
								<xsl:value-of select="$prevWord"/>
							</xsl:element>
							<!-- <xsl:element  name ="svg:tspan" ><xsl:attribute  name ="text-anchor" ><xsl:value-of  select =" $textAnchor" /></xsl:attribute><xsl:attribute  name ="x" ><xsl:value-of  select =" $tspanX" /></xsl:attribute><xsl:attribute  name ="y" ><xsl:value-of  select =" $lineHeight  *  $noOfLine  +  $tspanY" /></xsl:attribute><xsl:value-of  select =" $word" /></xsl:element> -->
						</xsl:if>
					</xsl:when>
					<xsl:when  test =" $size  =  1  and  string-length ( normalize-space ( $prevWord ))  >  0" >
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
							<xsl:variable name="finalWord" >
								<xsl:call-template name="slice_text">
									<xsl:with-param name="textField" select="$prevWord"/>
									<xsl:with-param name="position" select="0"/>
									<xsl:with-param name="finalText" select="''"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

								</xsl:call-template>
							</xsl:variable>
							<xsl:element name="line">
								<xsl:value-of select="$prevWord"/>
							</xsl:element>
							<!-- <xsl:element name="svg:tspan"><xsl:attribute name="text-anchor"><xsl:value-of select="$textAnchor"/></xsl:attribute><xsl:attribute name="x"><xsl:value-of select="$tspanX"/></xsl:attribute><xsl:attribute name="y"><xsl:value-of select="$lineHeight * $noOfLine + $tspanY"/></xsl:attribute><xsl:value-of select="$finalWord"/></xsl:element> -->
						</xsl:if>
						<xsl:call-template  name ="wordwrap_createtspan_cal_totalTextHeight" >
							<xsl:with-param  name ="node"  select =" $node" />
							<xsl:with-param  name ="position"  select =" $position" />
							<xsl:with-param  name ="word"  select =" normalize-space ( $node [ $position ])" />
							<xsl:with-param  name ="size"  select =" $size" />
							<xsl:with-param  name ="noOfLine"  select =" $noOfLine  +  1" />
							<xsl:with-param  name ="textWidth"  select =" $textWidth" />
							<xsl:with-param name="textHeight" select="$textHeight"/>
							<xsl:with-param  name ="fontFamily"  select =" $fontFamily" />
							<xsl:with-param  name ="fontStyle"  select =" $fontStyle" />
							<xsl:with-param  name ="fontSize"  select =" $fontSize" />
							<xsl:with-param  name ="fontWeight"  select =" $fontWeight" />
							<xsl:with-param  name ="lineHeight"  select =" $lineHeight" />
							<xsl:with-param  name ="textLineHeight"  select =" $textLineHeight" />
							<xsl:with-param  name ="textAnchor"  select =" $textAnchor" />
							<xsl:with-param  name ="currencyFormatType"  select =" $currencyFormatType" />
							<xsl:with-param  name ="currencySign"  select =" $currencySign" />
							<xsl:with-param  name ="tspanX"  select =" $tspanX" />
							<xsl:with-param  name ="tspanY"  select =" $tspanY" />
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$size = 1">
						<xsl:choose>
							<xsl:when test="contains($node, $currencySign) and $currencySign!= ''">
								<xsl:call-template name="additionalCurrencyFormatting">
									<xsl:with-param name="currencyfiedString" select="$node"/>
									<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
									<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
									<xsl:with-param name="currencySign" select="$currencySign"/>
									<xsl:with-param name="textAnchor" select="$textAnchor"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="lineHeight" select="$lineHeight"/>
									<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									<xsl:with-param name="noOfLine" select="0"/>
									<xsl:with-param name="tspanX" select="$tspanX"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                  <xsl:with-param name="currencyPosition" select="$currencyPosition"></xsl:with-param>
                  <xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"></xsl:with-param>                  
									<xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"></xsl:with-param>
                  <xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"></xsl:with-param>
									<xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"></xsl:with-param>
									<xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"></xsl:with-param>
									<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"></xsl:with-param>
									<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"></xsl:with-param>
									<xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"></xsl:with-param>
									<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"></xsl:with-param>
									<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"></xsl:with-param>
									<xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"></xsl:with-param>
									<xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"></xsl:with-param>
									<xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"></xsl:with-param>
									<xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"></xsl:with-param>

								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
									<xsl:element name="line">
										<xsl:value-of select="$prevWord"/>
									</xsl:element>
									<!-- <xsl:element name="svg:tspan"><xsl:attribute name="text-anchor"><xsl:value-of select="$textAnchor"/></xsl:attribute><xsl:attribute name="x"><xsl:value-of select="$tspanX"/></xsl:attribute><xsl:attribute name="y"><xsl:value-of select="$lineHeight * $noOfLine + $tspanY"/></xsl:attribute><xsl:value-of select="$word"/></xsl:element> -->
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$size &gt; 1">
						<xsl:call-template name="wordwrap_createtspan_cal_totalTextHeight">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="position" select="$position + 1"/>
							<xsl:with-param name="prevWord" select="$word"/>
							<xsl:with-param name="word" select="(concat($word,' ',$node[$position+1]))"/>
							<xsl:with-param name="size" select="$size - 1"/>
							<xsl:with-param name="noOfLine" select="$noOfLine"/>
							<xsl:with-param name="textAnchor" select="$textAnchor"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="textHeight" select="$textHeight"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="lineHeight" select="$lineHeight"/>
							<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
							<xsl:with-param name="currencySign" select="$currencySign"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
							<xsl:with-param name="tspanX" select="$tspanX"/>
							<xsl:with-param name="tspanY" select="$tspanY"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="wordwrap_createtspan">
		<xsl:param name="node"/>
		<xsl:param name="position"/>
		<xsl:param name="prevWord"/>
		<xsl:param name="word"/>
		<xsl:param name="size"/>
		<xsl:param name="noOfLine"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="textHeight"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="textLineHeight"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="currencyFormat"/>
		<xsl:param name="currencyFormatType"/>
		<xsl:param name="currencyfiedString"/>
		<xsl:param name="currencySign"/>
		<xsl:param name="totalLines"/>
    <xsl:param name="verticalAlignOffset"/>
    <xsl:param name="text_decoration_overline"/>    
    <xsl:param name="text_decoration_underline"/>    
    <xsl:param name="text_decoration_strikethrough"/> 
    <xsl:param name="zeroformatEnabled"/> 
    <xsl:param name="letterSpacing"/>
    <xsl:param name="isScalingTextFit"/>
    <xsl:param name="isScalingTextFitUpscalingAllowed"/>
    <xsl:param name="currencyPosition"/>
    <xsl:param name="customCurrencyFormatName"/>  
    <xsl:param name="customCurrencyThousandSeparator"/>  
		<xsl:param name="currencySignDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalSeperatorVisible"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalPortionVisible"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
		<xsl:param name="isCustomCurrencyFormat"/>
		<xsl:param name="currencySizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalSeperatorSizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalPortionSizeRatioWithFontSize"/>

		<xsl:choose>

           <!-- ========================== -->
        <!-- PATCH: handle forced newline -->
        <!-- ========================== -->
      <xsl:when test="$node[$position] = $FORCED_NL_TOKEN">
        <!-- flush current line if prevWord has content -->
        <xsl:if test="string-length(normalize-space($prevWord)) &gt; 0">
          <svg:tspan text-anchor="{$textAnchor}" 
                        x="{$tspanX}" 
                        y="{$lineHeight * $noOfLine + $tspanY + $verticalAlignOffset}">
            <xsl:value-of select="$prevWord"/>
          </svg:tspan>
        </xsl:if>
        <!-- continue recursion after newline -->
        <xsl:if test="$size &gt; 1">
          <xsl:call-template name="wordwrap_createtspan">
            <xsl:with-param name="node" select="$node"/>
            <xsl:with-param name="position" select="$position + 1"/>
            <xsl:with-param name="prevWord" select="''"/>
            <xsl:with-param name="word" select="$node[$position + 1]"/>
            <xsl:with-param name="size" select="$size - 1"/>
            <xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
            <xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
            <!-- pass through other params -->
            <xsl:with-param name="textAnchor" select="$textAnchor"/>
            <xsl:with-param name="textWidth" select="$textWidth"/>
            <xsl:with-param name="textHeight" select="$textHeight"/>
            <xsl:with-param name="lineHeight" select="$lineHeight"/>
            <xsl:with-param name="textLineHeight" select="$textLineHeight"/>
            <xsl:with-param name="tspanX" select="$tspanX"/>
            <xsl:with-param name="tspanY" select="$tspanY"/>
            <xsl:with-param name="fontStyle" select="$fontStyle"/>
            <xsl:with-param name="fontFamily" select="$fontFamily"/>
            <xsl:with-param name="fontWeight" select="$fontWeight"/>
            <xsl:with-param name="fontSize" select="$fontSize"/>
            <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
            <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
            <xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
            <xsl:with-param name="currencySign" select="$currencySign"/>
            <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
            <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
            <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>
            <xsl:with-param name="currencyPosition" select="$currencyPosition"/>
            <xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"/>
            <xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"/>
            <xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"/>
            <xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"/>
            <xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"/>
            <xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
            <xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
            <xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"/>
            <xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
            <xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
            <xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"/>
            <xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"/>
            <xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"/>
            <xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>


			<xsl:when test="dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily , $fontWeight , $fontStyle, $fontSize) >= $textWidth and $size > 1">
				<xsl:choose>
					<!-- check if prevword can only accomodate since current word has greater width -->
					<xsl:when test="(dgext:getTextWidth(concat('',$letterSpacing,''),$prevWord, $fontFamily , $fontWeight , $fontStyle, $fontSize) &gt; 0) and (dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily , $fontWeight , $fontStyle, $fontSize) > $textWidth) and (dgext:getTextWidth(concat('',$letterSpacing,''),$prevWord, $fontFamily , $fontWeight , $fontStyle, $fontSize) &lt; $textWidth)">
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
							<xsl:element name="svg:tspan">
								<xsl:attribute name="text-anchor">
									<xsl:value-of select="$textAnchor"/>
								</xsl:attribute>
								<xsl:attribute name="x">
									<xsl:value-of select="$tspanX"/>
								</xsl:attribute>
								<xsl:attribute name="y">
									<xsl:value-of select="$lineHeight * $noOfLine + $tspanY + $verticalAlignOffset"/>
								</xsl:attribute>
								<xsl:value-of select="$prevWord"/>
							</xsl:element>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="count($node) > $position">
								<xsl:call-template name="wordwrap_createtspan">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="position" select="$position+1"/>
									<xsl:with-param name="prevWord" select="$node[$position]"></xsl:with-param>
									<xsl:with-param name="word" select="(concat($node[$position],' ',$node[$position+1]))"/>
									<xsl:with-param name="size" select="$size - 1"/>
									<xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
									<xsl:with-param name="textAnchor" select="$textAnchor"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
									<xsl:with-param name="textHeight" select="$textHeight"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="lineHeight" select="$lineHeight"/>
									<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
									<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
									<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
									<xsl:with-param name="currencySign" select="$currencySign"/>
									<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									<xsl:with-param name="tspanX" select="$tspanX"/>
									<xsl:with-param name="tspanY" select="$tspanY"/>
									<xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
									<xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
									<xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
                  <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                  <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
                  <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>

								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="wordwrap_createtspan">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="position" select="$position"/>
									<xsl:with-param name="prevWord" select="$node[$position]"></xsl:with-param>
									<xsl:with-param name="word" select="($node[$position])"/>
									<xsl:with-param name="size" select="$size"/>
									<xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
									<xsl:with-param name="textAnchor" select="$textAnchor"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
									<xsl:with-param name="textHeight" select="$textHeight"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="lineHeight" select="$lineHeight"/>
									<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									<xsl:with-param name="tspanX" select="$tspanX"/>
									<xsl:with-param name="tspanY" select="$tspanY"/>
									<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
									<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
									<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
									<xsl:with-param name="currencySign" select="$currencySign"/>
									<xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
									<xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
									<xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
                  <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                  <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
                  <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>

								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight)">
							<xsl:variable name="finalWord" >
								<xsl:call-template name="slice_text">
									<xsl:with-param name="textField" select="$word"/>
									<xsl:with-param name="position" select="0"/>
									<xsl:with-param name="finalText" select="''"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

								</xsl:call-template>
							</xsl:variable>
							<xsl:element name="svg:tspan">
								<xsl:attribute name="text-anchor">
									<xsl:value-of select="$textAnchor"/>
								</xsl:attribute>
								<xsl:attribute name="x">
									<xsl:value-of select="$tspanX"/>
								</xsl:attribute>
								<xsl:attribute name="y">
									<xsl:value-of select="$lineHeight * $noOfLine + $tspanY + $verticalAlignOffset"/>
								</xsl:attribute>
								<xsl:value-of select="$finalWord"/>
							</xsl:element>
						</xsl:if>
						<xsl:call-template name="wordwrap_createtspan">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="position" select="$position + 1"/>
							<xsl:with-param name="word" select="($node[$position+1])"/>
							<xsl:with-param name="size" select="$size - 1"/>
							<xsl:with-param name="noOfLine" select="$noOfLine + 1"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="textHeight" select="$textHeight"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="lineHeight" select="$lineHeight"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
							<xsl:with-param name="textAnchor" select="$textAnchor"/>
							<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
							<xsl:with-param name="currencySign" select="$currencySign"/>
							<xsl:with-param name="tspanX" select="$tspanX"/>
							<xsl:with-param name="tspanY" select="$tspanY"/>
							<xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
              <xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
              <xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
              <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
              <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
              <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
              <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>

              </xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$size = 1 and ($textWidth >= dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily , $fontWeight , $fontStyle, $fontSize))  and $currencyFormatType = '' and (not($isCustomCurrencyFormat = 'true'))">
            <xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
              <xsl:variable name="horizontalAlignOffset">
                <xsl:if test="$textAnchor = 'start'">
                  <xsl:value-of select="0"/>
                </xsl:if>
                <xsl:if test="$textAnchor = 'middle'">
                  <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                </xsl:if>
                <xsl:if test="$textAnchor = 'end'">
                  <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                </xsl:if>
              </xsl:variable>		
              <xsl:if test="$text_decoration_underline = 'underline' and $currencySign != ''">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="isNoCurrenctFormat2SpecialCondition" select="'true'"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline' and $currencySign != ''">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$word, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="isNoCurrenctFormat2SpecialCondition" select="'true'"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
						  </xsl:if>
            <xsl:element  name ="svg:tspan" >
              <xsl:choose>
                <xsl:when test="$currencySign != ''">    
                  <xsl:attribute  name ="x" >
                    <xsl:value-of  select =" $tspanX + $horizontalAlignOffset" />
                  </xsl:attribute>
                  <xsl:attribute  name ="y" >
                    <xsl:value-of  select =" $lineHeight  *  $noOfLine  +  $tspanY + $verticalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:value-of  select =" $word" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute  name ="text-anchor" >
                    <xsl:value-of  select =" $textAnchor" />
                  </xsl:attribute>
                  <xsl:attribute  name ="x" >
                    <xsl:value-of  select =" $tspanX" />
                  </xsl:attribute>
                  <xsl:attribute  name ="y" >
                    <xsl:value-of  select =" $lineHeight  *  $noOfLine  +  $tspanY + $verticalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough' and $text_decoration_overline = 'overline' and $text_decoration_underline = 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'overline underline line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$text_decoration_strikethrough != 'strikethrough' and $text_decoration_overline = 'overline' and $text_decoration_underline = 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'overline underline'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough' and $text_decoration_overline = '!overline' and $text_decoration_underline = 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'underline line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough' and $text_decoration_overline = 'overline' and $text_decoration_underline != 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'overline line-through'"/>
                    </xsl:attribute>
                  </xsl:if>   
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough' and $text_decoration_overline != 'overline' and $text_decoration_underline != 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>       
                  <xsl:if test="$text_decoration_strikethrough != 'strikethrough' and $text_decoration_overline = 'overline' and $text_decoration_underline != 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'overline'"/>
                    </xsl:attribute>
                  </xsl:if>    
                  <xsl:if test="$text_decoration_strikethrough != 'strikethrough' and $text_decoration_overline != 'overline' and $text_decoration_underline = 'underline'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'underline'"/>
                    </xsl:attribute>
                  </xsl:if>           
                  <xsl:value-of  select =" $word" />	
                </xsl:otherwise>
              </xsl:choose>
            </xsl:element>
						</xsl:if>
					</xsl:when>
					<xsl:when  test =" $size  =  1  and  string-length ( normalize-space ( $prevWord ))  >  0" >
						<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">
							<xsl:variable name="finalWord" >
								<xsl:call-template name="slice_text">
									<xsl:with-param name="textField" select="$prevWord"/>
									<xsl:with-param name="position" select="0"/>
									<xsl:with-param name="finalText" select="''"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

								</xsl:call-template>
							</xsl:variable>
							<xsl:element name="svg:tspan">
								<xsl:attribute name="text-anchor">
									<xsl:value-of select="$textAnchor"/>
								</xsl:attribute>
								<xsl:attribute name="x">
									<xsl:value-of select="$tspanX"/>
								</xsl:attribute>
								<xsl:attribute name="y">
									<xsl:value-of select="$lineHeight * $noOfLine + $tspanY + $verticalAlignOffset"/>
								</xsl:attribute>
								<xsl:value-of select="$finalWord"/>
							</xsl:element>
						</xsl:if>
						<xsl:call-template  name ="wordwrap_createtspan" >
							<xsl:with-param  name ="node"  select =" $node" />
							<xsl:with-param  name ="position"  select =" $position" />
							<xsl:with-param  name ="word"  select =" normalize-space ( $node [ $position ])" />
							<xsl:with-param  name ="size"  select =" $size" />
							<xsl:with-param  name ="noOfLine"  select =" $noOfLine  +  1" />
							<xsl:with-param  name ="textWidth"  select =" $textWidth" />
							<xsl:with-param name="textHeight" select="$textHeight"/>
							<xsl:with-param  name ="fontFamily"  select =" $fontFamily" />
							<xsl:with-param  name ="fontStyle"  select =" $fontStyle" />
							<xsl:with-param  name ="fontSize"  select =" $fontSize" />
							<xsl:with-param  name ="fontWeight"  select =" $fontWeight" />
							<xsl:with-param  name ="lineHeight"  select =" $lineHeight" />
							<xsl:with-param  name ="textLineHeight"  select =" $textLineHeight" />
							<xsl:with-param  name ="textAnchor"  select =" $textAnchor" />
							<xsl:with-param  name ="currencyFormatType"  select =" $currencyFormatType" />
							<xsl:with-param  name ="currencySign"  select =" $currencySign" />
							<xsl:with-param  name ="tspanX"  select =" $tspanX" />
							<xsl:with-param  name ="tspanY"  select =" $tspanY" />
							<xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
              <xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
              <xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
              <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
              <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
              <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
              <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>
              </xsl:call-template>
					</xsl:when>
					<xsl:when test="$size = 1">
						<xsl:choose>
							<xsl:when test="contains($node, $currencySign) and $currencySign!= ''">
								<xsl:call-template name="additionalCurrencyFormatting">
									<xsl:with-param name="currencyfiedString" select="$node"/>
									<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
									<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
									<xsl:with-param name="currencySign" select="$currencySign"/>
									<xsl:with-param name="textAnchor" select="$textAnchor"/>
									<xsl:with-param name="textWidth" select="$textWidth"/>
									<xsl:with-param name="fontFamily" select="$fontFamily"/>
									<xsl:with-param name="fontStyle" select="$fontStyle"/>
									<xsl:with-param name="fontSize" select="$fontSize"/>
									<xsl:with-param name="fontWeight" select="$fontWeight"/>
									<xsl:with-param name="lineHeight" select="$lineHeight"/>
									<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									<xsl:with-param name="noOfLine" select="0"/>
									<xsl:with-param name="tspanX" select="$tspanX"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
                  <xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
                  <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>                  
                  <xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"/>
                  <xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"></xsl:with-param>
                  <xsl:with-param name="currencyPosition" select="$currencyPosition"></xsl:with-param>
									<xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"></xsl:with-param>
									<xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"></xsl:with-param>
									<xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"></xsl:with-param>
									<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"></xsl:with-param>
									<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"></xsl:with-param>
									<xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"></xsl:with-param>
									<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"></xsl:with-param>
									<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"></xsl:with-param>
									<xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"></xsl:with-param>
									<xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"></xsl:with-param>
									<xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"></xsl:with-param>
									<xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"></xsl:with-param>

								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
												<xsl:if test="$noOfLine &lt; (($textHeight - $lineHeight) div $lineHeight) or ($noOfLine = 0)">

							<xsl:variable name="finalWord" >
                <xsl:if test="$isScalingTextFit = 'true'">
                  <xsl:if test="$isScalingTextFitUpscalingAllowed = 'true'"> 
                    <xsl:call-template name="getTextWithoutSliced">
                    <xsl:with-param name="textField" select="$word"/>
                  </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="$isScalingTextFitUpscalingAllowed != 'true'">
                    <xsl:if test="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) &lt; $textWidth)">
                      <xsl:call-template name="slice_text">
                        <xsl:with-param name="textField" select="$word"/>
                        <xsl:with-param name="position" select="0"/>
                        <xsl:with-param name="finalText" select="''"/>
                        <xsl:with-param name="fontFamily" select="$fontFamily"/>
                        <xsl:with-param name="fontWeight" select="$fontWeight"/>
                        <xsl:with-param name="fontStyle" select="$fontStyle"/>
                        <xsl:with-param name="fontSize" select="$fontSize"/>
                        <xsl:with-param name="textWidth" select="$textWidth"/>
                        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                      </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) &gt;= $textWidth)">
                      
                        <xsl:call-template name="getTextWithoutSliced">
                          <xsl:with-param name="textField" select="$word"/>
                        </xsl:call-template>
                      
                    </xsl:if>
                  </xsl:if>
                </xsl:if>
                <xsl:if test="$isScalingTextFit != 'true'">
                      <xsl:call-template name="slice_text">
                        <xsl:with-param name="textField" select="$word"/>
                        <xsl:with-param name="position" select="0"/>
                        <xsl:with-param name="finalText" select="''"/>
                        <xsl:with-param name="fontFamily" select="$fontFamily"/>
                        <xsl:with-param name="fontWeight" select="$fontWeight"/>
                        <xsl:with-param name="fontStyle" select="$fontStyle"/>
                        <xsl:with-param name="fontSize" select="$fontSize"/>
                        <xsl:with-param name="textWidth" select="$textWidth"/>
                        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                      </xsl:call-template>
                </xsl:if>
							</xsl:variable>
              <!-- 
              <xsl:if test="$letterSpacing = 0">
														<xsl:if test="$text_decoration_underline = 'underline'">
															<xsl:call-template name="createFontStyleLineEffectSpan">
																<xsl:with-param name="tspanX" select="$tspanX"/>
																<xsl:with-param name="tspanY" select="$tspanY"/>
																<xsl:with-param name="text_decoration" select="'underline'"/>
																<xsl:with-param name="lineHeight" select="$lineHeight"/>
																<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
																<xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$finalWord, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
																<xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$finalWord, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
																<xsl:with-param name="spaceString" select="'&#160;'"/>
																<xsl:with-param name="fontFamily" select="$fontFamily"/>
																<xsl:with-param name="fontWeight" select="$fontWeight"/>
																<xsl:with-param name="fontStyle" select="$fontStyle"/>
																<xsl:with-param name="fontSize" select="$fontSize"/>
																<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
																<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
																<xsl:with-param name="currencySign" select="$currencySign"/>
																<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
															</xsl:call-template>
														</xsl:if>
														<xsl:if test="$text_decoration_overline = 'overline'">
															<xsl:call-template name="createFontStyleLineEffectSpan">
																<xsl:with-param name="tspanX" select="$tspanX"/>
																<xsl:with-param name="tspanY" select="$tspanY"/>
																<xsl:with-param name="text_decoration" select="'overline'"/>
																<xsl:with-param name="lineHeight" select="$lineHeight"/>
																<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
																<xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$finalWord, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
																<xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$finalWord, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
																<xsl:with-param name="spaceString" select="'&#160;'"/>
																<xsl:with-param name="fontFamily" select="$fontFamily"/>
																<xsl:with-param name="fontWeight" select="$fontWeight"/>
																<xsl:with-param name="fontStyle" select="$fontStyle"/>
																<xsl:with-param name="fontSize" select="$fontSize"/>
																<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
																<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
																<xsl:with-param name="currencySign" select="$currencySign"/>
																<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
															</xsl:call-template>
														</xsl:if>
													</xsl:if>	
                -->
              <xsl:element name="svg:tspan">
								<xsl:attribute name="text-anchor">
									<xsl:value-of select="$textAnchor"/>
								</xsl:attribute>
								<xsl:attribute name="x">
									<xsl:value-of select="$tspanX"/>
								</xsl:attribute>
								<xsl:attribute name="y">
									<xsl:value-of select="$lineHeight * $noOfLine + $tspanY + $verticalAlignOffset"/>
								</xsl:attribute>
								<xsl:value-of select="$finalWord"/>
							</xsl:element>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$size &gt; 1">
						<xsl:call-template name="wordwrap_createtspan">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="position" select="$position + 1"/>
							<xsl:with-param name="prevWord" select="$word"/>
							<xsl:with-param name="word" select="(concat($word,' ',$node[$position+1]))"/>
							<xsl:with-param name="size" select="$size - 1"/>
							<xsl:with-param name="noOfLine" select="$noOfLine"/>
							<xsl:with-param name="textAnchor" select="$textAnchor"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="textHeight" select="$textHeight"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="lineHeight" select="$lineHeight"/>
							<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
							<xsl:with-param name="currencySign" select="$currencySign"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
							<xsl:with-param name="tspanX" select="$tspanX"/>
							<xsl:with-param name="tspanY" select="$tspanY"/>
							<xsl:with-param name="verticalAlignOffset" select="$verticalAlignOffset"/>
              <xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
              <xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
              <xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
              <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
              <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
              <xsl:with-param name="isScalingTextFit" select="$isScalingTextFit"/>
              <xsl:with-param name="isScalingTextFitUpscalingAllowed" select="$isScalingTextFitUpscalingAllowed"/>

              </xsl:call-template>
					</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="split">
      <xsl:param name="pText" select="."/>
      <xsl:param name="pDelim" select="' '"/>
      <xsl:param name="pElemName" select="'word'"/>
      <xsl:param name="letterSpacing"/>

      <xsl:if test="string-length(($pText))">
      <xsl:element name="{$pElemName}">
      <xsl:value-of select="substring-before(concat($pText,$pDelim),$pDelim)"/>
      </xsl:element>
      <xsl:variable name="ptextAfterLastSpaceCheck">
      <xsl:choose>
        <xsl:when test="string-length(substring-after($pText,$pDelim)) = 0 and substring($pText, string-length($pText)) = ' ' and $pText != ' '">
          <xsl:value-of select="' '"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($pText,$pDelim)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>  
    <xsl:call-template name="split">
      <xsl:with-param name="pText" select="$ptextAfterLastSpaceCheck"/>
    <xsl:with-param name="pDelim" select="$pDelim"/>
    <xsl:with-param name="pElemName" select="$pElemName"/>
    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

    </xsl:call-template>
      </xsl:if>
      </xsl:template>
      <xsl:template name="getValueAsTreeElement">
      <xsl:param name="pText" select="."/>
      <xsl:param name="pElemName" select="'word'"/>
      <xsl:element name="{$pElemName}">
        <xsl:value-of select="$pText"/>
      </xsl:element>
    </xsl:template><xsl:template name="charwrap">
		<xsl:param name="textAnchor"/>
		<xsl:param name="productFieldValue"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="textHeight"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="textLineHeight"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="currencySign"/>
		<xsl:param name="currencyPosition"/>
		<xsl:param name="currencyFormat"/>
    <xsl:param name="currencyFormatType"/>
    <xsl:param name="currencyCode"/>
    <xsl:param name="textVertAlign"/>
    <xsl:param name="zeroformatEnabled"/>
    <xsl:param name="text_decoration_overline"/>    
    <xsl:param name="text_decoration_underline"/>    
    <xsl:param name="text_decoration_strikethrough"/>
    <xsl:param name="isToApplyUpperCase"/>
    <xsl:param name="isToApplyLowerCase"/>
    <xsl:param name="letterSpacing"/>
    <xsl:param name="customCurrencyFormatName"/>
    <xsl:param name="customCurrencyThousandSeparator"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalSeperatorVisible"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalPortionVisible"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
		<xsl:param name="isCustomCurrencyFormat"/>
		<xsl:param name="currencySizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalSeperatorSizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalPortionSizeRatioWithFontSize"/>
		<xsl:param name="noOfLine" select="0"/>
    <xsl:param name="isSplitting"/>
		<xsl:param name="splitBy"/>

    <xsl:variable name="addedSlashnForSplit">
      <xsl:choose>
        <xsl:when test="$isSplitting = 'true'">
          <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="$productFieldValue" />
            <xsl:with-param name="replace" select="$splitBy" />
            <xsl:with-param name="by" select="'\n'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$productFieldValue" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

		<xsl:variable name="modified">
			<xsl:call-template name="replace-backslash-n">
				<xsl:with-param name="text" select="$addedSlashnForSplit" />
				<xsl:with-param name="accum" select="''" />
			</xsl:call-template>
		</xsl:variable>

    <xsl:variable name="productFieldValue1">
      <xsl:choose>
        <xsl:when test="contains($modified, '1_quot_1')">
          <xsl:value-of select='concat(substring-before($modified, "1_quot_1"),"&#39;",substring-after($modified, "1_quot_1"))'/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$modified"/>
        </xsl:otherwise>
      </xsl:choose>	    
    </xsl:variable>

  		<xsl:variable name="commaValidation">
			<xsl:value-of select="translate($productFieldValue1, ',', '.')"/>
		</xsl:variable>

		<xsl:variable name="newtSpanX">
			<xsl:value-of  select="$tspanX"/>
		</xsl:variable>

		<xsl:variable name="currencyfiedString">
			<xsl:choose>
				<xsl:when test="number($productFieldValue1) = $productFieldValue1">
					<xsl:call-template name="addCurrencySign">
						<xsl:with-param name="productFieldValue" select="$commaValidation"/>
						<xsl:with-param name="currencySign" select="$currencySign"/>
						<xsl:with-param name="currencyPosition" select="$currencyPosition"/>
						<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
						<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
						<xsl:with-param name="currencyCode" select="$currencyCode"/>
						<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="number($commaValidation) = $commaValidation">
					<xsl:call-template name="addCurrencySign">
						<xsl:with-param name="productFieldValue" select="$commaValidation"/>
						<xsl:with-param name="currencySign" select="$currencySign"/>
						<xsl:with-param name="currencyPosition" select="$currencyPosition"/>
						<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
						<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
						<xsl:with-param name="currencyCode" select="$currencyCode"/>
						<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$isToApplyUpperCase = 'true'">
							<xsl:value-of  select="translate($productFieldValue1,$smallcase,$uppercase)"/>
						</xsl:when>
						<xsl:when test="$isToApplyLowerCase = 'true'">
							<xsl:value-of  select="translate($productFieldValue1,$uppercase,$smallcase)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$productFieldValue1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>



		<xsl:if test="string-length(normalize-space($currencyfiedString)) &gt; 0">
			<!-- <xsl:variable name="breakIndex">
				<xsl:call-template name="binarySearchWidth_charWrap">
					<xsl:with-param name="theText" select="$currencyfiedString"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="low" select="1"/>
					<xsl:with-param name="high" select="string-length($currencyfiedString)"/>
					<xsl:with-param name="maxWidth" select="$textWidth"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="lineToOutput" select="substring($currencyfiedString, 1, $breakIndex)"/> -->

			<!-- Split and wrap -->
			<xsl:variable name="linesElement">
				<!-- <xsl:call-template name="charwrap_calc_lines">
					<xsl:with-param name="productFieldValue" select="$currencyfiedString"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="textHeight" select="$textHeight"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="position" select="1"/>
					<xsl:with-param name="noOfLine" select="0"/>
					<xsl:with-param name="breakIndex" select="$breakIndex"/>
					<xsl:with-param name="currentLine" select="$lineToOutput"/>
				</xsl:call-template> -->

				<xsl:call-template name="split-and-wrap-lines">
					<xsl:with-param name="text" select="$currencyfiedString"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="textHeight" select="$textHeight"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="linesArray" select="ext:node-set($linesElement)/*"/>
			<xsl:variable name="maxLinesAllowed" select="round($textHeight div $lineHeight)"/>
			<xsl:variable name="linesToRender">
				<xsl:choose>
					<xsl:when test="count($linesArray) &gt; $maxLinesAllowed">
						<xsl:value-of select="$maxLinesAllowed"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count($linesArray)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
      <xsl:variable name="verticalAlignOffset">
				<xsl:choose>
					<xsl:when test="$textVertAlign = 'middle'">
						<xsl:value-of select="(($lineHeight * (number($linesToRender) - 1)) * 0.5)"/>
					</xsl:when>
					<xsl:when test="$textVertAlign = 'bottom'">
						<xsl:value-of select="($lineHeight * (number($linesToRender) - 1))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:for-each select="$linesArray[position() &lt;= $linesToRender]">
         <svg:tspan x="{$tspanX}" y="{$tspanY - $verticalAlignOffset + ($lineHeight * (position() - 1))}">
        
					<xsl:attribute name="text-anchor">
						<xsl:value-of select="$textAnchor"/>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</svg:tspan>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	
	<!-- Recursive replacement template -->
	<xsl:template name="replace-backslash-n">
		<xsl:param name="text" />
		<xsl:param name="accum" />
		<xsl:choose>
			<xsl:when test="contains($text, '\n')">
				<xsl:variable name="before" select="substring-before($text, '\n')" />
				<xsl:variable name="after" select="substring-after($text, '\n')" />
				<xsl:call-template name="replace-backslash-n">
					<xsl:with-param name="text" select="$after" />
					<xsl:with-param name="accum" select="concat($accum, $before, 'U+000A')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($accum, $text)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Entry point: split lines and wrap -->
	<xsl:template name="split-and-wrap-lines">
		<xsl:param name="text"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="textVertAlign"/>
		<!-- Container for tspans -->
		<xsl:call-template name="split-by-newline-and-wrap">
			<xsl:with-param name="text" select="$text"/>
			<xsl:with-param name="textWidth" select="$textWidth"/>
			<xsl:with-param name="fontFamily" select="$fontFamily"/>
			<xsl:with-param name="fontStyle" select="$fontStyle"/>
			<xsl:with-param name="fontWeight" select="$fontWeight"/>
			<xsl:with-param name="fontSize" select="$fontSize"/>
			<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
			<xsl:with-param name="lineHeight" select="$lineHeight"/>
			<xsl:with-param name="tspanX" select="$tspanX"/>
			<xsl:with-param name="tspanY" select="$tspanY"/>
			<xsl:with-param name="textAnchor" select="$textAnchor"/>
			<xsl:with-param name="lineIndex" select="0"/>
			<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Splits text by and wraps each line -->
	<xsl:template name="split-by-newline-and-wrap">
		<xsl:param name="text"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="lineIndex"/>
		<xsl:param name="textVertAlign"/>
		<xsl:choose>
			<xsl:when test="contains($text, 'U+000A')">
				<xsl:variable name="currentLine" select="substring-before($text, 'U+000A')"/>
				<xsl:variable name="rest" select="substring-after($text, 'U+000A')"/>
				<xsl:call-template name="wrap-line">
					<xsl:with-param name="line" select="$currentLine"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
				</xsl:call-template>
				<xsl:call-template name="split-by-newline-and-wrap">
					<xsl:with-param name="text" select="$rest"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex + 1"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="wrap-line">
					<xsl:with-param name="line" select="$text"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Wraps line into multiple tspans based on width -->
	<xsl:template name="wrap-line">
		<xsl:param name="line"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="lineIndex"/>
		<xsl:param name="textVertAlign"/>
		<xsl:if test="string-length($line) &gt; 0">
			<xsl:variable name="splitPos">
				<xsl:call-template name="binarySearchWidth_charWrap">
					<xsl:with-param name="text" select="$line"/>
					<xsl:with-param name="low" select="1"/>
					<xsl:with-param name="high" select="string-length($line)"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
				</xsl:call-template>
			</xsl:variable>
			<!-- Print one line -->
			<line>
				<xsl:value-of select="normalize-space(substring($line, 1, $splitPos))"/>
			</line>
			<xsl:variable name="remaining" select="substring($line, $splitPos + 1)"/>
			<xsl:if test="string-length($remaining) &gt; 0">
				<xsl:call-template name="wrap-line">
					<xsl:with-param name="line" select="$remaining"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex + 1"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Binary search to find max fitting characters -->
	<xsl:template name="binarySearchWidth_charWrap">
		<xsl:param name="text"/>
		<xsl:param name="low"/>
		<xsl:param name="high"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:choose>
			<xsl:when test="$low &gt; $high">
				<xsl:value-of select="$low - 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="mid" select="floor(($low + $high) div 2)"/>
				<xsl:variable name="substring" select="substring($text, 1, $mid)"/>
				<xsl:variable name="width" select="dgext:getTextWidth($letterSpacing, $substring, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
				<xsl:choose>
					<xsl:when test="$width &lt;= $textWidth">
						<xsl:call-template name="binarySearchWidth_charWrap">
							<xsl:with-param name="text" select="$text"/>
							<xsl:with-param name="low" select="$mid + 1"/>
							<xsl:with-param name="high" select="$high"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="binarySearchWidth_charWrap">
							<xsl:with-param name="text" select="$text"/>
							<xsl:with-param name="low" select="$low"/>
							<xsl:with-param name="high" select="$mid - 1"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	<xsl:template name="divFormat">
		<xsl:param name="calcValue"/>
		<xsl:param name="calcDivFormat"/>
		<xsl:param name="letterSpacing"/>
    <xsl:param name="roundFormat"/>
    <xsl:param name="formatValue"/>
		<xsl:variable name="formattedString">
			<xsl:choose>
				<xsl:when test="$calcDivFormat = 'NCO'">
          <xsl:variable name="f1String">
            <xsl:value-of select="string(format-number($calcValue, '0.000'))"/>
          </xsl:variable>
          <xsl:value-of select="number(concat(substring-before($f1String, '.'), '.', substring($f1String,string-length(substring-before($f1String, '.'))+2,2)))"/>
				</xsl:when>
				<xsl:when test="$calcDivFormat = '1f'">
            <xsl:choose>
            <xsl:when test="$roundFormat = 'default' ">
              <xsl:variable name="f1String">
                <xsl:value-of select="string(format-number($calcValue, '0.000'))"/>
              </xsl:variable>
              <xsl:value-of select="concat(substring-before($f1String, '.'), '.', substring($f1String,string-length(substring-before($f1String, '.'))+2,1))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="roundOffTemplate">
                <xsl:with-param name="roundOffData" select="$calcValue"/>
                <xsl:with-param name="roundFormat" select="$roundFormat"/>
                <xsl:with-param name="calcDivFormat" select="$calcDivFormat"/>
                <xsl:with-param name="formatValue" select="'0.0'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
				</xsl:when>
				<xsl:when test="$calcDivFormat = '2f'">
          <xsl:choose>
          <xsl:when test="$roundFormat = 'default' ">
            <xsl:variable name="f1String">
              <xsl:value-of select="string(format-number($calcValue, '0.000'))"/>
            </xsl:variable>
            <xsl:value-of select="concat(substring-before($f1String, '.'), '.', substring($f1String,string-length(substring-before($f1String, '.'))+2,2))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="roundOffTemplate">
                <xsl:with-param name="roundOffData" select="$calcValue"/>    
                <xsl:with-param name="roundFormat" select="$roundFormat"/>    
                <xsl:with-param name="calcDivFormat" select="$calcDivFormat"/>
                <xsl:with-param name="formatValue" select="'0.00'"/>
            </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
				</xsl:when>
				<xsl:when test="$calcDivFormat = '3f'">
				<xsl:choose>
            <xsl:when test="$roundFormat = 'default' ">
              <xsl:variable name="f1String">
                <xsl:value-of select="string(format-number($calcValue, '0.0000'))"/>
              </xsl:variable>
              <xsl:value-of select="concat(substring-before($f1String, '.'), '.', substring($f1String,string-length(substring-before($f1String, '.'))+2,3))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="roundOffTemplate">
                  <xsl:with-param name="roundOffData" select="$calcValue"/>    
                  <xsl:with-param name="roundFormat" select="$roundFormat"/>    
                  <xsl:with-param name="calcDivFormat" select="$calcDivFormat"/>
                  <xsl:with-param name="formatValue" select="'0.000'"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
				</xsl:when>
				<xsl:when test="$calcDivFormat = '1f_'">
        <xsl:choose>
        <xsl:when test="$roundFormat = 'default' ">
          <xsl:variable name="f1String">
            <xsl:value-of select="string(format-number($calcValue, '0.000'))"/>
          </xsl:variable>
          <xsl:value-of select="concat(substring-before($f1String, '.'), ',', substring($f1String,string-length(substring-before($f1String, '.'))+2, 1))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="roundOffTemplate">
              <xsl:with-param name="roundOffData" select="$calcValue"/>    
              <xsl:with-param name="roundFormat" select="$roundFormat"/>    
              <xsl:with-param name="calcDivFormat" select="$calcDivFormat"/>
              <xsl:with-param name="formatValue" select="'0.0'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
				</xsl:when>
				<xsl:when test="$calcDivFormat = '2f_'">
        <xsl:choose>
        <xsl:when test="$roundFormat = 'default' ">
          <xsl:variable name="f1String">
            <xsl:value-of select="string(format-number($calcValue, '0.000'))"/>
          </xsl:variable>
          <xsl:value-of select="concat(substring-before($f1String, '.'), ',', substring($f1String,string-length(substring-before($f1String, '.'))+2,2))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="roundOffTemplate">
              <xsl:with-param name="roundOffData" select="$calcValue"/>    
              <xsl:with-param name="roundFormat" select="$roundFormat"/>    
              <xsl:with-param name="calcDivFormat" select="$calcDivFormat"/>
              <xsl:with-param name="formatValue" select="'0.00'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
				</xsl:when>
				<xsl:when test="$calcDivFormat = '3f_'">
        <xsl:choose>
        <xsl:when test="$roundFormat = 'default' ">
          <xsl:variable name="f1String">
            <xsl:value-of select="string(format-number($calcValue, '0.0000'))"/>
          </xsl:variable>
          <xsl:value-of select="concat(substring-before($f1String, '.'), ',', substring($f1String,string-length(substring-before($f1String, '.'))+2,3))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="roundOffTemplate">
              <xsl:with-param name="roundOffData" select="$calcValue"/>    
              <xsl:with-param name="roundFormat" select="$roundFormat"/>    
              <xsl:with-param name="calcDivFormat" select="$calcDivFormat"/>
              <xsl:with-param name="formatValue" select="'0.000'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="f1String">
						<xsl:value-of select="string(format-number($calcValue, '0.000'))"/>
					</xsl:variable>
					<xsl:value-of select="substring-before($f1String, '.')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$formattedString"/>
	</xsl:template><xsl:template name="addCurrencySign">
		<xsl:param name="productFieldValue"/>
		<xsl:param name="currencySign"/>
		<xsl:param name="currencyPosition"/>
		<xsl:param name="currencyFormat"/>
		<xsl:param name="zeroformatEnabled"/>
		<xsl:param name="currencyCode"/>		
    <xsl:param name="letterSpacing"/>

		<xsl:variable name="decimalFormat">
			<xsl:choose>
        <xsl:when test="$currencyFormat = 'euro' and $currencyCode = 'PC'">
          <xsl:variable name="decimalFormatPc">
            <xsl:value-of select='format-number(number($productFieldValue), "###.##0,00", "euro")'/>
          </xsl:variable>
          <xsl:value-of select='substring-before($decimalFormatPc, ",")'/>
        </xsl:when>
				<xsl:when test="$currencyFormat = 'euro' and $zeroformatEnabled = 'false'">
        <xsl:choose>
        <xsl:when test="substring(substring-after($productFieldValue, '.'), 2,1) = '0'">
          <xsl:value-of select='format-number(number($productFieldValue), "###.##0,00", "euro")'/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select='format-number(number($productFieldValue), "###.##0,##", "euro")'/>
        </xsl:otherwise>
      </xsl:choose>
				</xsl:when>
				<xsl:when test="$currencyFormat = 'euro' and $zeroformatEnabled = 'true'">
					<xsl:value-of select='format-number(number($productFieldValue), "###.##0,00", "euro")'/>
				</xsl:when>
				<xsl:when test="$currencyFormat = 'usa' and $zeroformatEnabled = 'false'">
          <xsl:choose>
            <xsl:when test="substring(substring-after($productFieldValue, '.'), 2,1) = '0'">
              <xsl:value-of select='format-number(number($productFieldValue), "###,##0.00", "usa")'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='format-number(number($productFieldValue), "###,##0.##", "usa")'/>
            </xsl:otherwise>
          </xsl:choose>
				</xsl:when>
				<xsl:when test="$currencyFormat = 'usa' and $zeroformatEnabled = 'true'">
					<xsl:value-of select='format-number(number($productFieldValue), "###,##0.00", "usa")'/>
				</xsl:when>
				<xsl:when test="$currencyFormat = 'thousandSeparator'">
					<xsl:value-of select='format-number(number($productFieldValue), "###,###.##", "usa")'/>
				</xsl:when>
        <xsl:when test="$currencyFormat = 'isIndianCurrency'">
          <xsl:variable name="indianCurrencyFormatValue">
            <xsl:choose>
              <xsl:when test="number($productFieldValue) >= 1000">
                <xsl:value-of select="format-number(floor(number($productFieldValue) div 1000), '#,##.##')" />
                <xsl:text>,</xsl:text>
                <xsl:value-of select="format-number(number($productFieldValue) mod 1000, '000.##')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="format-number(number($productFieldValue), '#,###.##')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="substring($productFieldValue, (string-length($productFieldValue) - string-length('.00')) + 1) = '.00'">
              <xsl:value-of select="concat($indianCurrencyFormatValue, '.00')"/>
            </xsl:when>
            <xsl:when test="substring($productFieldValue, (string-length($productFieldValue) - string-length('.0')) + 1) = '.0'">
              <xsl:value-of select="concat($indianCurrencyFormatValue, '.0')"/>
            </xsl:when>
            <xsl:when test="contains($productFieldValue, '.') and substring($productFieldValue, (string-length($productFieldValue) - string-length('0')) + 1) = '0'">
              <xsl:value-of select="concat($indianCurrencyFormatValue, '0')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$indianCurrencyFormatValue"/>
            </xsl:otherwise>
          </xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$productFieldValue"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="currencyfiedString">
			<xsl:choose>
				<xsl:when test="$currencyPosition = 'end'">
					<xsl:value-of select="concat($decimalFormat, $currencySign)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($currencySign, $decimalFormat)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$currencyfiedString"/>
	</xsl:template><xsl:template name="additionalCurrencyFormatting">
    <xsl:param name="currencyfiedString"/>
    <xsl:param name="currencyFormat"/>
    <xsl:param name="currencyFormatType"/>
    <xsl:param name="currencySign"/>
    <xsl:param name="textAnchor"/>
    <xsl:param name="fontFamily"/>
    <xsl:param name="fontWeight"/>
    <xsl:param name="fontStyle"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="textWidth"/>
    <xsl:param name="textHeight"/>
    <xsl:param name="lineHeight"/>
    <xsl:param name="textLineHeight"/>
    <xsl:param name="tspanX"/>
    <xsl:param name="tspanY"/>
    <xsl:param name="text_decoration_overline"/>
    <xsl:param name="text_decoration_underline"/>
    <xsl:param name="text_decoration_strikethrough"/>
    <xsl:param name="zeroformatEnabled"/>
    <xsl:param name="letterSpacing"/>
    <xsl:param name="currencyPosition"/>    
    <xsl:param name="customCurrencyFormatName"/>
    <xsl:param name="customCurrencyThousandSeparator"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencySignDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalSeperatorVisible"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
		<xsl:param name="currencyIsDecimalPortionVisible"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
		<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
		<xsl:param name="isCustomCurrencyFormat"/>
		<xsl:param name="currencySizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalSeperatorSizeRatioWithFontSize"/>
		<xsl:param name="currencyDecimalPortionSizeRatioWithFontSize"/>

    <xsl:choose>
    <!--		  New Logic for generic currency format-->
			<xsl:when test="$isCustomCurrencyFormat = 'true'">
				<!--Variable Declaration-->
				<xsl:variable name="currencyStartString">
					<xsl:choose>
						<xsl:when test="$currencySign != '' and $currencyPosition = 'start'">
							<xsl:value-of select="$currencySign"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="''"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="priceBeforeDecimalString">
        <xsl:choose>
            <!-- Chitra -->
            <!-- 1 - Default cond -->
						<xsl:when test="$currencyFormat = 'euro' and (not(contains($currencyfiedString, ','))) and $customCurrencyThousandSeparator = 'true'">
							<xsl:value-of select="translate($currencyfiedString , $currencySign,'' )"/>
						</xsl:when>
            
            <xsl:when test="$currencyFormat = 'euro' and (not(contains($currencyfiedString, ','))) and $customCurrencyThousandSeparator = 'false'">
              <xsl:value-of select="translate($currencyfiedString, concat($currencySign, '.'), '')"/>
            </xsl:when>

            <!-- 2 - Default cond-->
						<xsl:when test="$currencyFormat = 'euro' and contains($currencyfiedString, ',') and $customCurrencyThousandSeparator = 'true'">
							<xsl:value-of select="substring-before(translate($currencyfiedString , $currencySign,'' ),',')"/>
						</xsl:when>
            
            <xsl:when test="$currencyFormat = 'euro' and contains($currencyfiedString, ',') and $customCurrencyThousandSeparator = 'false'">
              <xsl:value-of select="translate(substring-before(translate($currencyfiedString , $currencySign,'' ),','), '.' , '') "/>
            </xsl:when>

            <!-- 3 - Default cond -->
						<xsl:when test="$currencyFormat = 'usa' and (not(contains($currencyfiedString, '.'))) and $customCurrencyThousandSeparator = 'true'">
							<xsl:value-of select="translate($currencyfiedString , $currencySign,'' )"/>
						</xsl:when>

            <xsl:when test="$currencyFormat = 'usa' and (not(contains($currencyfiedString, '.'))) and $customCurrencyThousandSeparator = 'false'">
              <xsl:value-of select="translate(translate($currencyfiedString , $currencySign,'' ), ',' , '')"/>
            </xsl:when>

            <!-- 4 - Default cond -->
            <xsl:when test="$currencyFormat = 'usa' and contains($currencyfiedString, '.') and $customCurrencyThousandSeparator = 'true'">
              <xsl:value-of select="substring-before(translate($currencyfiedString , $currencySign,'' ),'.')"/>
            </xsl:when>

						<xsl:when test="$currencyFormat = 'usa' and contains($currencyfiedString, '.') and $customCurrencyThousandSeparator = 'false'">
              <xsl:value-of select="translate(substring-before(translate($currencyfiedString , $currencySign,'' ), '.'), ',', '')"/>
						</xsl:when>

            <!-- Chitra -->

            <xsl:otherwise>
							<xsl:value-of select="''"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="currencyIsDecimalSeperatorString">
					<xsl:choose>
						<xsl:when test="$currencyIsDecimalSeperatorVisible = 'true' and $currencyFormat = 'euro' and contains($currencyfiedString, ',')">
							<xsl:value-of select="','"/>
						</xsl:when>
						<xsl:when test="$currencyIsDecimalSeperatorVisible = 'true' and $currencyFormat = 'usa' and contains($currencyfiedString, '.')">
							<xsl:value-of select="'.'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="''"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="currencyDecimalPortionString">
					<xsl:choose>
						<xsl:when test="$currencyIsDecimalPortionVisible = 'true' and $currencyFormat = 'euro' and contains($currencyfiedString, ',')">
						  <xsl:choose>
						    <xsl:when test="$zeroformatEnabled = 'true' and (string-length(substring-after($currencyfiedString, ',')) = 1)">
						      <xsl:value-of select="concat(substring-after($currencyfiedString, ','),'0')"/>
						    </xsl:when>
						    <xsl:when test="$zeroformatEnabled = 'true' and (string-length(substring-after($currencyfiedString, ',')) = 0)">
						      <xsl:value-of select="'00'"/>
						    </xsl:when>
						    <xsl:otherwise>
						      <xsl:value-of select="substring-after(translate($currencyfiedString , $currencySign,'' ),',')"/>
						    </xsl:otherwise>
						  </xsl:choose>
						</xsl:when>
						<xsl:when test="$currencyIsDecimalPortionVisible = 'true' and $currencyFormat = 'usa' and contains($currencyfiedString, '.')">
						  <xsl:choose>
						    <xsl:when test="$zeroformatEnabled = 'true' and (string-length(substring-after($currencyfiedString, '.')) = 1)">
						      <xsl:value-of select="concat(substring-after($currencyfiedString, '.'),'0')"/>
						    </xsl:when>
						    <xsl:when test="$zeroformatEnabled = 'true' and (string-length(substring-after($currencyfiedString, '.')) = 0)">
						      <xsl:value-of select="'00'"/>
						    </xsl:when>
						    <xsl:otherwise>
						      <xsl:value-of select="substring-after(translate($currencyfiedString , $currencySign,'' ),'.')"/>
						    </xsl:otherwise>
						  </xsl:choose>
						</xsl:when>
						<xsl:otherwise>
						  <xsl:choose>
						    <xsl:when test="$currencyIsDecimalPortionVisible = 'true' and $zeroformatEnabled = 'true'">
						      <xsl:value-of select="00"/>
						    </xsl:when>
						    <xsl:otherwise>
						        <xsl:value-of select="''"/>
						    </xsl:otherwise>
						  </xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="currencyEndString">
					<xsl:choose>
						<xsl:when test="$currencySign != '' and $currencyPosition = 'end'">
							<xsl:value-of select="$currencySign"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="''"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="totalWidthCalculated">
					<xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
						+ ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))
						+ ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyIsDecimalSeperatorString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalSeperatorSizeRatioWithFontSize))))
						+ ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyDecimalPortionString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalPortionSizeRatioWithFontSize))))
						+ ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyEndString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))"/>
				</xsl:variable>
				<xsl:variable name="horizontalAlignOffset">
					<xsl:if test="$textAnchor = 'start'">
						<xsl:value-of select="0"/>
					</xsl:if>
					<xsl:if test="$textAnchor = 'middle'">
						<xsl:value-of select="($textWidth - $totalWidthCalculated) div 2"/>
					</xsl:if>
					<xsl:if test="$textAnchor = 'end'">
						<xsl:value-of select="($textWidth - $totalWidthCalculated)"/>
					</xsl:if>
				</xsl:variable>
				<!--Variable Declaration End-->
				<xsl:if test="$currencySign != '' and $currencyPosition = 'start'">
					<xsl:element name="svg:tspan">
						<xsl:attribute name="x">
              <xsl:choose>
								<xsl:when test="not($currencySignDisplacementRatioWithFontSizeX = '')">
                  <xsl:value-of select="$tspanX + ($fontSize div $currencySignDisplacementRatioWithFontSizeX) + $horizontalAlignOffset"/>	
								</xsl:when>
								<xsl:otherwise>
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="y">
							<xsl:choose>
								<xsl:when test="not($currencySignDisplacementRatioWithFontSizeY = '')">
									<xsl:value-of select="$tspanY - ($fontSize div $currencySignDisplacementRatioWithFontSizeY)"/>							
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$tspanY"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="style">
							<xsl:value-of select="concat('font-size: ',($fontSize div $currencySizeRatioWithFontSize),'px;')"/>
						</xsl:attribute>
						<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
							<xsl:attribute name="text-decoration">
								<xsl:value-of select="'line-through'"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$currencyStartString"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="svg:tspan">
					<xsl:attribute name="x">
						<xsl:value-of select="$tspanX + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))"/>
					</xsl:attribute>
					<xsl:attribute name="y">
						<xsl:value-of select="$tspanY"/>
					</xsl:attribute>
					<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
						<xsl:attribute name="text-decoration">
							<xsl:value-of select="'line-through'"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$priceBeforeDecimalString"/>
				</xsl:element>
				<xsl:if test="$currencyIsDecimalSeperatorVisible = 'true'">
					<xsl:element name="svg:tspan">
						<xsl:attribute name="x">
              <xsl:choose>
								<xsl:when test="not($currencyDecimalSeperatorDisplacementRatioWithFontSizeX = '')">
                  <xsl:value-of select="$tspanX + ($fontSize div $currencyDecimalSeperatorDisplacementRatioWithFontSizeX) + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
								</xsl:when>
								<xsl:otherwise>
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="y">
							<xsl:choose>
								<xsl:when test="not($currencyDecimalSeperatorDisplacementRatioWithFontSizeY = '')">
									<xsl:value-of select="$tspanY - ($fontSize div $currencyDecimalSeperatorDisplacementRatioWithFontSizeY)"/>							
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$tspanY"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
							<xsl:attribute name="text-decoration">
								<xsl:value-of select="'line-through'"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
							<xsl:attribute name="text-decoration">
								<xsl:value-of select="'line-through'"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:attribute name="style">
							<xsl:value-of select="concat('font-size: ',($fontSize div $currencyDecimalSeperatorSizeRatioWithFontSize),'px;')"/>
						</xsl:attribute>
						<xsl:value-of select="$currencyIsDecimalSeperatorString"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="$currencyIsDecimalPortionVisible = 'true'">
					<xsl:element name="svg:tspan">
						<xsl:attribute name="x">
              <xsl:choose>
								<xsl:when test="not($currencyDecimalPortionDisplacementRatioWithFontSizeX = '')">
                  <xsl:value-of select="$tspanX + ($fontSize div $currencyDecimalPortionDisplacementRatioWithFontSizeX) + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyIsDecimalSeperatorString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalSeperatorSizeRatioWithFontSize))))"/>
								</xsl:when>
								<xsl:otherwise>
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyIsDecimalSeperatorString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalSeperatorSizeRatioWithFontSize))))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="y">
							<xsl:choose>
								<xsl:when test="not($currencyDecimalPortionDisplacementRatioWithFontSizeY = '')">
									<xsl:value-of select="$tspanY - ($fontSize div $currencyDecimalPortionDisplacementRatioWithFontSizeY)"/>							
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$tspanY"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
							<xsl:attribute name="text-decoration">
								<xsl:value-of select="'line-through'"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
							<xsl:attribute name="text-decoration">
								<xsl:value-of select="'line-through'"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:attribute name="style">
							<xsl:value-of select="concat('font-size: ',($fontSize div $currencyDecimalPortionSizeRatioWithFontSize),'px;')"/>
						</xsl:attribute>
						<xsl:value-of select="$currencyDecimalPortionString"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="$currencySign != '' and $currencyPosition = 'end'">
					<xsl:element name="svg:tspan">
						<xsl:attribute name="x">
              <xsl:choose>
								<xsl:when test="not($currencySignDisplacementRatioWithFontSizeX = '')">
                  <xsl:value-of select="$tspanX + ($fontSize div $currencySignDisplacementRatioWithFontSizeX) + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyIsDecimalSeperatorString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalSeperatorSizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyDecimalPortionString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalPortionSizeRatioWithFontSize))))"/>
								</xsl:when>
								<xsl:otherwise>
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyStartString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencySizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$priceBeforeDecimalString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyIsDecimalSeperatorString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalSeperatorSizeRatioWithFontSize))))
                  + ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyDecimalPortionString, $fontFamily, $fontWeight, $fontStyle, ($fontSize div $currencyDecimalPortionSizeRatioWithFontSize))))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="y">
							<xsl:choose>
								<xsl:when test="not($currencySignDisplacementRatioWithFontSizeY = '')">
									<xsl:value-of select="$tspanY - ($fontSize div $currencySignDisplacementRatioWithFontSizeY)"/>							
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$tspanY"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="style">
							<xsl:value-of select="concat('font-size: ',($fontSize div $currencySizeRatioWithFontSize),'px;')"/>
						</xsl:attribute>
						<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
							<xsl:attribute name="text-decoration">
								<xsl:value-of select="'line-through'"/>
							</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$currencyEndString"/>
					</xsl:element>
				</xsl:if>
				<!--		  New Logic for generic currency format End-->
			</xsl:when>
      <xsl:when test="$currencyFormat = 'euro'">
        <xsl:choose>
          <!-- Format 1 EURO -->
          <xsl:when test="$currencyFormatType = '1'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = concat('00',$currencySign)">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$currencyfiedString"></xsl:value-of>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize )"/>
                    <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                  <xsl:attribute name="text-decoration">
                    <xsl:value-of select="'line-through'"/>
                  </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="$currencyfiedString"></xsl:value-of>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Format 1 EURO ends -->
          <!-- Format 2 EURO -->
          <xsl:when test="$currencyFormatType = '2'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = concat('00',$currencySign)">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                  <xsl:attribute name="text-decoration">
                    <xsl:value-of select="'line-through'"/>
                  </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring-before($currencyfiedString, ',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)  + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, ',') != concat('00',$currencySign) and (contains($currencyfiedString, ','))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring-before($currencyfiedString, ',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)  + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, $currencySign)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) "/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Format 2 EURO ends -->
          <!-- Format 3 EURO -->
          <xsl:when test="$currencyFormatType = '3'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = '00'">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString,',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                            select="substring($currencyfiedString, string-length($currencyfiedString) - 1, 2)"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, ',') != '00' and (contains($currencyfiedString, ','))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString,',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                            select="substring($currencyfiedString, string-length($currencyfiedString) - 1, 2)"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="$currencyfiedString"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!--- Format 3 EURO ends-->
          <!-- Format 11 EURO -->
          <xsl:when test="$currencyFormatType = '11'">
          <xsl:choose>
            <xsl:when test="substring-after($currencyfiedString, ',') = concat('00',$currencySign)">
              <xsl:variable name="horizontalAlignOffset">
                <xsl:if test="$textAnchor = 'start'">
                  <xsl:value-of select="0"/>
                </xsl:if>
                <xsl:if test="$textAnchor = 'middle'">
                  <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                </xsl:if>
                <xsl:if test="$textAnchor = 'end'">
                  <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                </xsl:if>
              </xsl:variable>
              <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:element name="svg:tspan">
                <xsl:attribute name="x">
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                  <xsl:value-of select="$tspanY"/>
                </xsl:attribute>
                <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                  <xsl:attribute name="text-decoration">
                    <xsl:value-of select="'line-through'"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$currencyfiedString"></xsl:value-of>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="horizontalAlignOffset">
                <xsl:if test="$textAnchor = 'start'">
                  <xsl:value-of select="0"/>
                </xsl:if>
                <xsl:if test="$textAnchor = 'middle'">
                  <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                </xsl:if>
                <xsl:if test="$textAnchor = 'end'">
                  <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                </xsl:if>
              </xsl:variable>
              <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize )"/>
                  <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="counter" select="dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:element name="svg:tspan">
                <xsl:attribute name="x">
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                </xsl:attribute>
                <xsl:attribute name="y">
                  <xsl:value-of select="$tspanY"/>
                </xsl:attribute>
                <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                <xsl:attribute name="text-decoration">
                  <xsl:value-of select="'line-through'"/>
                </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$currencyfiedString"></xsl:value-of>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
          </xsl:when>
          <!--- Format 11 EURO ends-->
					<!-- Format 12 starts -->
          
					<xsl:when test="$currencyFormatType='12'">
						<xsl:choose>
							<xsl:when test="substring-after($currencyfiedString, ',') = '00'">
								<xsl:variable name="horizontalAlignOffset">
									<xsl:if test="$textAnchor = 'start'">
										<xsl:value-of select="0"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'middle'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))) div 2"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'end'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)))))"/>
									</xsl:if>
								</xsl:variable>
								<xsl:if test="$text_decoration_underline = 'underline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'underline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$text_decoration_overline = 'overline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'overline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 3.2"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough' and normalize-space(substring($currencyfiedString, 1, 1)) != '&#160;'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 4)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize) ) + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 2.1"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 3),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2)"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="substring-after($currencyfiedString, ',') != '00' and (contains($currencyfiedString, ','))">
								<xsl:variable name="horizontalAlignOffset">
									<xsl:if test="$textAnchor = 'start'">
										<xsl:value-of select="0"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'middle'">
										<xsl:choose>
											<xsl:when test="string-length(substring-after($currencyfiedString, ',')) = 1 ">
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))) div 2"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))) div 2"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="$textAnchor = 'end'">
										<xsl:choose>
											<xsl:when test="string-length(substring-after($currencyfiedString, ',')) = 1 ">
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)))))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)))))"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</xsl:variable>
								<xsl:variable name="widthManipulated">
									<xsl:choose>
										<xsl:when test="string-length(substring-after($currencyfiedString, ',')) = 1 ">
											<xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:if test="$text_decoration_underline = 'underline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'underline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="$widthManipulated"/>
										<xsl:with-param name="counter" select="$widthManipulated"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$text_decoration_overline = 'overline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'overline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="$widthManipulated"/>
										<xsl:with-param name="counter" select="$widthManipulated"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 3.2"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough' and normalize-space(substring($currencyfiedString, 1, 1)) != '&#160;'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="string-length(substring-after($currencyfiedString, ',')) = 1 ">
											<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 3)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 4)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:choose>
											<xsl:when test="string-length(substring-after($currencyfiedString, ',')) = 1 ">
												<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)  + dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize div 3)) + $horizontalAlignOffset"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize) + dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize div 3) ) + $horizontalAlignOffset"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 2.1"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 3),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="string-length(substring-after($currencyfiedString, ',')) = 1 ">
											<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="horizontalAlignOffset">
									<xsl:if test="$textAnchor = 'start'">
										<xsl:value-of select="0"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'middle'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'end'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
									</xsl:if>
								</xsl:variable>
								<xsl:if test="$text_decoration_underline = 'underline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'underline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$text_decoration_overline = 'overline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'overline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 3.2"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough' and normalize-space(substring($currencyfiedString, 1, 1)) != '&#160;'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring-after($currencyfiedString, $currencySign)"/>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- Format 12 ends -->
          <!-- Format 7 EURO -->
          <xsl:when test="$currencyFormatType = '7'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = concat('00',$currencySign)">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                  <xsl:attribute name="text-decoration">
                    <xsl:value-of select="'line-through'"/>
                  </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring-before($currencyfiedString, ',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring-after($currencyfiedString, ',')"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, ',') != concat('00',$currencySign) and (contains($currencyfiedString, ','))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="substring-before($currencyfiedString, ',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-after($currencyfiedString, ',')"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, $currencySign)"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Format 7 EURO ends -->
          <!-- Format 8 EURO -->
          <xsl:when test="$currencyFormatType = '8'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = '00'">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="concat(substring-before($currencyfiedString,','),',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, ','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                    select="substring-after($currencyfiedString, ',')"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, ',') != '00' and (contains($currencyfiedString, ','))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="concat(substring-before($currencyfiedString,','),',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, ','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                    select="substring-after($currencyfiedString, ',')"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="$currencyfiedString"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!--- Format 8 EURO ends-->
          <!-- Format 9 EURO -->
          <xsl:when test="$currencyFormatType = '9'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = '00'">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="concat(substring-before($currencyfiedString,','),',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, ','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="dy">
                    <xsl:value-of select="- $fontSize div 2.5"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                    select="substring-after($currencyfiedString, ',')"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, ',') != '00' and (contains($currencyfiedString, ','))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString,','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, ','), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="concat(substring-before($currencyfiedString,','),',')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, ','),','), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="dy">
                    <xsl:value-of select="- $fontSize div 2.5"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                    select="substring-after($currencyfiedString, ',')"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="$currencyfiedString"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!--- Format 9 EURO ends-->
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, ',') = '00'">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                            select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) "/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                          select="substring($currencyfiedString, string-length($currencyfiedString) - 1, 2)"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, ',') != '00' and (contains($currencyfiedString, ','))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                            select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after(substring($currencyfiedString, 1, string-length($currencyfiedString)-2), $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) "/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                          select="substring($currencyfiedString, string-length($currencyfiedString) - 1, 2)"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                            select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-after($currencyfiedString, $currencySign)"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$currencyFormat = 'usa'">
        <xsl:choose>
        <!-- US Format 10 for no currency sign -->
          <xsl:when test="$currencyFormatType='10' and $currencySign='&#160;'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, '.') = '00&#160;'">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, string-length($currencyfiedString)-3)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                      select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-4), $fontFamily, $fontWeight, $fontStyle, $fontSize)" />
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 3.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.6),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                    select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"
                  />
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, '.') != '00&#160;' and (contains($currencyfiedString, '.'))">
                <xsl:variable name="makeFixupto2DigitAppendZero">
                   <xsl:choose>
                    <xsl:when test="string-length ( normalize-space (substring-after($currencyfiedString,'.')))  =  2 ">
                      <xsl:value-of select="'0'"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="''"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, '.'), '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, '.'), '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, '.'), '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, '.'), '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, '.'), '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),concat(substring-before($currencyfiedString, '.'), '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="concat(substring-before($currencyfiedString, '.'), '.')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                      select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,'.'), $fontFamily, $fontWeight, $fontStyle, $fontSize)" />
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 3.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.6),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                    select="concat(translate(substring-after($currencyfiedString, '.'),'&#160;',''), $makeFixupto2DigitAppendZero)"
                  />
                </xsl:element> 
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, $currencySign)" />
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- US Format 10 for no currency sign ends here-->
          <!-- US Format 1-->
          <xsl:when test="$currencyFormatType='1' and $currencySign='&#160;'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, '.') = '00&#160;'">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, string-length($currencyfiedString)-3)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize)" />
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
              select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"
            />
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, '.') != '00&#160;' and (contains($currencyfiedString, '.'))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, string-length($currencyfiedString)-3)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-3), $fontFamily, $fontWeight, $fontStyle, $fontSize)" />
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
              select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"
            />
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize ))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, $currencySign)" />
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$currencyFormatType = '1'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, '.') = concat('00',$currencySign)">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, $currencySign)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                </xsl:element>
              </xsl:when>
              <xsl:when test="substring-after($currencyfiedString, '.') != concat('00',$currencySign) and (contains($currencyfiedString, '.'))">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
              <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, $currencySign)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                  <xsl:value-of select="$tspanX + $horizontalAlignOffset + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-1), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-1), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-1), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-1), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-1), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, string-length($currencyfiedString)-1), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, 1, string-length($currencyfiedString)-1)"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;' )"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- US Format 1 ends-->
          <!-- Format 2 USA -->
          <xsl:when test="$currencyFormatType = '2'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, '.') = concat('00',$currencySign)">
                <xsl:variable name="textWidthForUsedCurrencyString">
                  <xsl:choose>
                      <xsl:when test="substring($currencyfiedString, string-length($currencyfiedString), 1) != '&#160;'">
                        <xsl:value-of select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + 5 +(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize )) + 5 +(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                      </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>  
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - $textWidthForUsedCurrencyString) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - $textWidthForUsedCurrencyString)"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="counter" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY - 1"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="counter" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, '.')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                          select="$tspanX + $horizontalAlignOffset+ dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize) + 5" />
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                        select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"
                      />
                </xsl:element>
                <xsl:if test="substring($currencyfiedString, string-length($currencyfiedString), 1) != '&#160;'">
                  <xsl:element name="svg:tspan">
                    <xsl:attribute name="x">
                      <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,'.'), $fontFamily, $fontWeight, $fontStyle, $fontSize) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + 5 + 5"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                      <xsl:value-of select="$tspanY"/>
                    </xsl:attribute>
                    <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                      <xsl:attribute name="text-decoration">
                        <xsl:value-of select="'line-through'"/>
                      </xsl:attribute>
                    </xsl:if>                  
                    <xsl:value-of
                          select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                  </xsl:element>
                </xsl:if>  
              </xsl:when>
              <xsl:when test="(substring-after($currencyfiedString, '.') != concat('00',$currencySign))  and (contains($currencyfiedString, '.'))">
              <xsl:variable name="textWidthForUsedCurrencyString">
                  <xsl:choose>
                    <xsl:when test="substring($currencyfiedString, string-length($currencyfiedString), 1) != '&#160;'">
                      <xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), 1), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + 5 + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + 5 + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))"/>
                    </xsl:otherwise>
                  </xsl:choose>
              </xsl:variable>  
              <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - $textWidthForUsedCurrencyString) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - $textWidthForUsedCurrencyString)"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="counter" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY - 1"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="counter" select="$textWidthForUsedCurrencyString"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="substring-before($currencyfiedString, '.')"/>
                </xsl:element>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of
                          select="$tspanX + $horizontalAlignOffset+ dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString, '.'), $fontFamily, $fontWeight, $fontStyle, $fontSize) + 5" />
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                  </xsl:attribute>
                  <xsl:attribute name="style">
                    <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of
                        select="substring($currencyfiedString, string-length($currencyfiedString) - 2, 2)"
                      />
                </xsl:element>
                <xsl:if test="substring($currencyfiedString, string-length($currencyfiedString), 1) != '&#160;'">
                  <xsl:element name="svg:tspan">
                    <xsl:attribute name="x">
                      <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),substring-before($currencyfiedString,'.'), $fontFamily, $fontWeight, $fontStyle, $fontSize) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + 5 + 5"/>
                    </xsl:attribute>
                    <xsl:attribute name="y">
                      <xsl:value-of select="$tspanY"/>
                    </xsl:attribute>
                    <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                      <xsl:attribute name="text-decoration">
                        <xsl:value-of select="'line-through'"/>
                      </xsl:attribute>
                    </xsl:if>                  
                    <xsl:value-of
                          select="substring($currencyfiedString, string-length($currencyfiedString), 1)"/>
                  </xsl:element>
                </xsl:if> 
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>  
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                  
                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
<xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
                    <xsl:with-param name="isNoCurrenctFormat2SpecialCondition" select="$zeroformatEnabled = 'false' and (not(contains($currencyfiedString, '.')) or not(contains($currencyfiedString, '.00')))"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>                  
                  <xsl:value-of select="$currencyfiedString"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Format 2 USA ends -->
          <!-- Format 3 USA -->
          <xsl:when test="$currencyFormatType = '3'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, '.') = concat('00',$currencySign)">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth -  (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of
                      select="$currencyfiedString"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth -  (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                  <xsl:attribute name="text-decoration">
                    <xsl:value-of select="'line-through'"/>
                  </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of
                      select="$currencyfiedString"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Format 3 USA ends -->
          
          <!-- Format 11 USA -->
          <xsl:when test="$currencyFormatType = '11'">
            <xsl:choose>
              <xsl:when test="substring-after($currencyfiedString, '.') = concat('00',$currencySign)">
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth -  (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                    <xsl:attribute name="text-decoration">
                      <xsl:value-of select="'line-through'"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of
                      select="$currencyfiedString"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="horizontalAlignOffset">
                  <xsl:if test="$textAnchor = 'start'">
                    <xsl:value-of select="0"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'middle'">
                    <xsl:value-of select="($textWidth - (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))) div 2"/>
                  </xsl:if>
                  <xsl:if test="$textAnchor = 'end'">
                    <xsl:value-of select="($textWidth -  (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$text_decoration_underline = 'underline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'underline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
              <xsl:if test="$text_decoration_overline = 'overline'">
                <xsl:call-template name="createFontStyleLineEffectSpan">
                  <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                  <xsl:with-param name="tspanY" select="$tspanY"/>
                  <xsl:with-param name="text_decoration" select="'overline'"/>
                  <xsl:with-param name="lineHeight" select="$lineHeight"/>
                  <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                  <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                  <xsl:with-param name="spaceString" select="'&#160;'"/>
                  <xsl:with-param name="fontFamily" select="$fontFamily"/>
                  <xsl:with-param name="fontWeight" select="$fontWeight"/>
                  <xsl:with-param name="fontStyle" select="$fontStyle"/>
                  <xsl:with-param name="fontSize" select="$fontSize"/>
                  <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                  <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                  <xsl:with-param name="currencySign" select="$currencySign"/>
                  <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                  <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                </xsl:call-template>
              </xsl:if>
                <xsl:element name="svg:tspan">
                  <xsl:attribute name="x">
                    <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                  </xsl:attribute>
                  <xsl:attribute name="y">
                    <xsl:value-of select="$tspanY"/>
                  </xsl:attribute>
                  <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                  <xsl:attribute name="text-decoration">
                    <xsl:value-of select="'line-through'"/>
                  </xsl:attribute>
                  </xsl:if>
                  <xsl:value-of
                      select="$currencyfiedString"/>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Format 11 USA ends -->
					<!-- Format 12 starts -->

          <xsl:when test="$currencyFormatType='12'">
						<xsl:choose>
							<xsl:when test="substring-after($currencyfiedString, '.') = '00'">
								<xsl:variable name="horizontalAlignOffset">
									<xsl:if test="$textAnchor = 'start'">
										<xsl:value-of select="0"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'middle'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))) div 2"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'end'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)))))"/>
									</xsl:if>
								</xsl:variable>
								<xsl:if test="$text_decoration_underline = 'underline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'underline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$text_decoration_overline = 'overline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'overline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 3.2"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough' and normalize-space(substring($currencyfiedString, 1, 1)) != '&#160;'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 4)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize) ) + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 2.1"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 3),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2)"/>
								</xsl:element>
							</xsl:when>
							<xsl:when test="substring-after($currencyfiedString, '.') != '00' and (contains($currencyfiedString, '.'))">
								<xsl:variable name="horizontalAlignOffset">
									<xsl:if test="$textAnchor = 'start'">
										<xsl:value-of select="0"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'middle'">
										<xsl:choose>
											<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))) div 2"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))) div 2"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="$textAnchor = 'end'">
										<xsl:choose>
											<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)))))"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)))))"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</xsl:variable>
								<xsl:variable name="widthManipulated">
									<xsl:choose>
										<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
											<xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3))))"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:if test="$text_decoration_underline = 'underline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'underline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="$widthManipulated"/>
										<xsl:with-param name="counter" select="$widthManipulated"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$text_decoration_overline = 'overline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'overline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="$widthManipulated"/>
										<xsl:with-param name="counter" select="$widthManipulated"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 3.2"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough' and normalize-space(substring($currencyfiedString, 1, 1)) != '&#160;'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
											<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 3)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 4)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:choose>
											<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
												<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)  + dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize div 3)) + $horizontalAlignOffset"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 3)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 4), $fontFamily, $fontWeight, $fontStyle, $fontSize) + dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize div 3) ) + $horizontalAlignOffset"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 2.1"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 3),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:choose>
										<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
											<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 2)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 2, string-length($currencyfiedString) - 2)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="horizontalAlignOffset">
									<xsl:if test="$textAnchor = 'start'">
										<xsl:value-of select="0"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'middle'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
									</xsl:if>
									<xsl:if test="$textAnchor = 'end'">
										<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
									</xsl:if>
								</xsl:variable>
								<xsl:if test="$text_decoration_underline = 'underline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'underline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="$text_decoration_overline = 'overline'">
									<xsl:call-template name="createFontStyleLineEffectSpan">
										<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="text_decoration" select="'overline'"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
										<xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
										<xsl:with-param name="spaceString" select="'&#160;'"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontSize" select="$fontSize"/>
										<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
										<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
										<xsl:with-param name="currencySign" select="$currencySign"/>
										<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:attribute name="dy">
										<xsl:value-of select="- $fontSize div 3.2"/>
									</xsl:attribute>
									<xsl:attribute name="style">
										<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough' and normalize-space(substring($currencyfiedString, 1, 1)) != '&#160;'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
								</xsl:element>
								<xsl:element name="svg:tspan">
									<xsl:attribute name="x">
										<xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
									</xsl:attribute>
									<xsl:attribute name="y">
										<xsl:value-of select="$tspanY"/>
									</xsl:attribute>
									<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
										<xsl:attribute name="text-decoration">
											<xsl:value-of select="'line-through'"/>
										</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring-after($currencyfiedString, $currencySign)"/>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- Format 12 ends -->
          <!-- Format 5 only for  USA $ and format4 for all others begins-->
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$currencyFormatType='5' and $currencySign='$'" >
                <xsl:choose>
                  <xsl:when test="substring-after($currencyfiedString, '.') = '00'">
                    <xsl:variable name="horizontalAlignOffset">
                      <xsl:if test="$textAnchor = 'start'">
                        <xsl:value-of select="0"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'middle'">
                        <xsl:value-of select="($textWidth - (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))) div 2"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'end'">
                        <xsl:value-of select="($textWidth -  (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:if test="$text_decoration_underline = 'underline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'underline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="$text_decoration_overline = 'overline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'overline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$currencyfiedString"/>
                    </xsl:element>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="horizontalAlignOffset">
                      <xsl:if test="$textAnchor = 'start'">
                        <xsl:value-of select="0"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'middle'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'end'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:if test="$text_decoration_underline = 'underline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'underline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="$text_decoration_overline = 'overline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'overline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="$currencyfiedString"/>
                    </xsl:element>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$currencyFormatType='5' and $currencySign='&#160;'">
                <xsl:choose>
                  <xsl:when test="substring-after($currencyfiedString, '.') = '00'">
                    <xsl:variable name="horizontalAlignOffset">
                      <xsl:if test="$textAnchor = 'start'">
                        <xsl:value-of select="0"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'middle'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'end'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:if test="$text_decoration_underline = 'underline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'underline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="$text_decoration_overline = 'overline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'overline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="$currencyfiedString"/>
                    </xsl:element>
                  </xsl:when>
                  <xsl:otherwise>
                  <xsl:variable name="horizontalAlignOffset">
                    <xsl:if test="$textAnchor = 'start'">
                      <xsl:value-of select="0"/>
                    </xsl:if>
                    <xsl:if test="$textAnchor = 'middle'">
                      <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                    </xsl:if>
                    <xsl:if test="$textAnchor = 'end'">
                      <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                    </xsl:if>
                  </xsl:variable>
                  <xsl:if test="$text_decoration_underline = 'underline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'underline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) - dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) - dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                <xsl:if test="$text_decoration_overline = 'overline'">
                  <xsl:call-template name="createFontStyleLineEffectSpan">
                    <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                    <xsl:with-param name="tspanY" select="$tspanY"/>
                    <xsl:with-param name="text_decoration" select="'overline'"/>
                    <xsl:with-param name="lineHeight" select="$lineHeight"/>
                    <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                    <xsl:with-param name="textWidth" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) - dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="counter" select="((dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) - dgext:getTextWidth(concat('',$letterSpacing,''),' ', $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                    <xsl:with-param name="spaceString" select="'&#160;'"/>
                    <xsl:with-param name="fontFamily" select="$fontFamily"/>
                    <xsl:with-param name="fontWeight" select="$fontWeight"/>
                    <xsl:with-param name="fontStyle" select="$fontStyle"/>
                    <xsl:with-param name="fontSize" select="$fontSize"/>
                    <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                    <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                    <xsl:with-param name="currencySign" select="$currencySign"/>
                    <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                    <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                  </xsl:call-template>
                </xsl:if>
                    <xsl:element name="svg:tspan">                      
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="substring($currencyfiedString,2, string-length($currencyfiedString) - 1)"/>
                    </xsl:element>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="substring-after($currencyfiedString, '.') = '00'">
                    <xsl:variable name="horizontalAlignOffset">
                      <xsl:if test="$textAnchor = 'start'">
                        <xsl:value-of select="0"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'middle'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'end'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:if test="$text_decoration_underline = 'underline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'underline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                      <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="$text_decoration_overline = 'overline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'overline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                      <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                      </xsl:attribute>
                      <xsl:attribute name="style">
                        <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
                    </xsl:element>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 3)"/>
                    </xsl:element>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize) ) + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:attribute name="style">
                        <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3)"/>
                    </xsl:element>
                  </xsl:when>
                  <xsl:when test="substring-after($currencyfiedString, '.') != '00' and (contains($currencyfiedString, '.'))">
										<xsl:variable name="horizontalAlignOffset">
											<xsl:if test="$textAnchor = 'start'">
												<xsl:value-of select="0"/>
											</xsl:if>
											<xsl:if test="$textAnchor = 'middle'">
												<xsl:choose>
													<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
														<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))))) div 2"/>
													</xsl:otherwise>
												</xsl:choose>

											</xsl:if>
											<xsl:if test="$textAnchor = 'end'">
												<xsl:choose>
													<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
														<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))))"/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:if>
										</xsl:variable>
										<xsl:variable name="widthManipulated">
											<xsl:choose>
													<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
														<xsl:value-of select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString), string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize)) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)))"/>
													</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:if test="$text_decoration_underline = 'underline'">
											<xsl:call-template name="createFontStyleLineEffectSpan">
												<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
												<xsl:with-param name="tspanY" select="$tspanY"/>
												<xsl:with-param name="text_decoration" select="'underline'"/>
												<xsl:with-param name="lineHeight" select="$lineHeight"/>
												<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
												<xsl:with-param name="textWidth" select="$widthManipulated"/>
												<xsl:with-param name="counter" select="$widthManipulated"/>
												<xsl:with-param name="spaceString" select="'&#160;'"/>
												<xsl:with-param name="fontFamily" select="$fontFamily"/>
												<xsl:with-param name="fontWeight" select="$fontWeight"/>
												<xsl:with-param name="fontStyle" select="$fontStyle"/>
												<xsl:with-param name="fontSize" select="$fontSize"/>
												<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
												<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
												<xsl:with-param name="currencySign" select="$currencySign"/>
												<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
											</xsl:call-template>
										</xsl:if>
										<xsl:if test="$text_decoration_overline = 'overline'">
											<xsl:call-template name="createFontStyleLineEffectSpan">
												<xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
												<xsl:with-param name="tspanY" select="$tspanY"/>
												<xsl:with-param name="text_decoration" select="'overline'"/>
												<xsl:with-param name="lineHeight" select="$lineHeight"/>
												<xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
												<xsl:with-param name="textWidth" select="$widthManipulated"/>
												<xsl:with-param name="counter" select="$widthManipulated"/>
												<xsl:with-param name="spaceString" select="'&#160;'"/>
												<xsl:with-param name="fontFamily" select="$fontFamily"/>
												<xsl:with-param name="fontWeight" select="$fontWeight"/>
												<xsl:with-param name="fontStyle" select="$fontStyle"/>
												<xsl:with-param name="fontSize" select="$fontSize"/>
												<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
												<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
												<xsl:with-param name="currencySign" select="$currencySign"/>
												<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
											</xsl:call-template>
										</xsl:if>

										<xsl:element name="svg:tspan">
											<xsl:attribute name="x">
												<xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
											</xsl:attribute>
											<xsl:attribute name="y">
												<xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
											</xsl:attribute>
											<xsl:attribute name="style">
												<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
											</xsl:attribute>
											<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
												<xsl:attribute name="text-decoration">
													<xsl:value-of select="'line-through'"/>
												</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
										</xsl:element>
										<xsl:element name="svg:tspan">
											<xsl:attribute name="x">
												<xsl:value-of select="$tspanX + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + $horizontalAlignOffset"/>
											</xsl:attribute>
											<xsl:attribute name="y">
												<xsl:value-of select="$tspanY"/>
											</xsl:attribute>
											<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
												<xsl:attribute name="text-decoration">
													<xsl:value-of select="'line-through'"/>
												</xsl:attribute>
											</xsl:if>
											<xsl:choose>
												<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
													<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 2)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="substring($currencyfiedString, 2, string-length($currencyfiedString) - 3)"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:element>
										<xsl:element name="svg:tspan">
											<xsl:attribute name="x">
												<xsl:choose>
													<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
														<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 2), $fontFamily, $fontWeight, $fontStyle, $fontSize) ) + $horizontalAlignOffset"/>
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="($tspanX +  dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8)) + dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 2, string-length($currencyfiedString) - 3), $fontFamily, $fontWeight, $fontStyle, $fontSize) ) + $horizontalAlignOffset"/>
													</xsl:otherwise>
												</xsl:choose>

											</xsl:attribute>
											<xsl:attribute name="y">
												<xsl:value-of select="$tspanY"/>
											</xsl:attribute>
											<xsl:attribute name="style">
												<xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
											</xsl:attribute>
											<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
												<xsl:attribute name="text-decoration">
													<xsl:value-of select="'line-through'"/>
												</xsl:attribute>
											</xsl:if>
											<xsl:choose>
												<xsl:when test="string-length(substring-after($currencyfiedString, '.')) = 1 ">
													<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString), string-length($currencyfiedString) - 2)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="substring($currencyfiedString, string-length($currencyfiedString) - 1, string-length($currencyfiedString) - 3)"/>
												</xsl:otherwise>
											</xsl:choose>

										</xsl:element>
									</xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="horizontalAlignOffset">
                      <xsl:if test="$textAnchor = 'start'">
                        <xsl:value-of select="0"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'middle'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize)))) div 2"/>
                      </xsl:if>
                      <xsl:if test="$textAnchor = 'end'">
                        <xsl:value-of select="($textWidth - ((dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))))"/>
                      </xsl:if>
                    </xsl:variable>
                    <xsl:if test="$text_decoration_underline = 'underline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'underline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                  <xsl:if test="$text_decoration_overline = 'overline'">
                    <xsl:call-template name="createFontStyleLineEffectSpan">
                      <xsl:with-param name="tspanX" select="$tspanX + $horizontalAlignOffset"/>
                      <xsl:with-param name="tspanY" select="$tspanY"/>
                      <xsl:with-param name="text_decoration" select="'overline'"/>
                      <xsl:with-param name="lineHeight" select="$lineHeight"/>
                      <xsl:with-param name="style" select="'stroke:rgb(0,0,0);'"/>
                      <xsl:with-param name="textWidth" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="counter" select="(dgext:getTextWidth(concat('',$letterSpacing,''),substring($currencyfiedString, 1, 1), $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))) + (dgext:getTextWidth(concat('',$letterSpacing,''),substring-after($currencyfiedString, $currencySign), $fontFamily, $fontWeight, $fontStyle, $fontSize))"/>
                      <xsl:with-param name="spaceString" select="'&#160;'"/>
                      <xsl:with-param name="fontFamily" select="$fontFamily"/>
                      <xsl:with-param name="fontWeight" select="$fontWeight"/>
                      <xsl:with-param name="fontStyle" select="$fontStyle"/>
                      <xsl:with-param name="fontSize" select="$fontSize"/>
                      <xsl:with-param name="currencyFormat" select="$currencyFormat"/>
                      <xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
                      <xsl:with-param name="currencySign" select="$currencySign"/>
                      <xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
                      <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

                    </xsl:call-template>
                  </xsl:if>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY - ($fontSize div 2.5)"/>
                      </xsl:attribute>
                      <xsl:attribute name="style">
                        <xsl:value-of select="concat('font-size: ',($fontSize div 1.8),'px;')"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="substring($currencyfiedString, 1, 1)"/>
                    </xsl:element>
                    <xsl:element name="svg:tspan">
                      <xsl:attribute name="x">
                        <xsl:value-of select="$tspanX + $horizontalAlignOffset + dgext:getTextWidth(concat('',$letterSpacing,''),$currencySign, $fontFamily, $fontWeight, $fontStyle, ($fontSize div 1.8))"/>
                      </xsl:attribute>
                      <xsl:attribute name="y">
                        <xsl:value-of select="$tspanY"/>
                      </xsl:attribute>
                      <xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
                        <xsl:attribute name="text-decoration">
                          <xsl:value-of select="'line-through'"/>
                        </xsl:attribute>
                      </xsl:if>                      
                      <xsl:value-of select="substring-after($currencyfiedString, $currencySign)"/>
                    </xsl:element>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
          <!-- Format 5 only for  USA $ and format4 for all others ends-->
          <!-- Format 2 USA ends -->
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="createFontStyleLineEffectSpan">
    <xsl:param name="tspanX"/>
    <xsl:param name="tspanY"/>
    <xsl:param name="text_decoration"/>
    <xsl:param name="lineHeight"/>
    <xsl:param name="style"/>
    <xsl:param name="textWidth"/>
    <xsl:param name="counter"/>
    <xsl:param name="spaceString"/>
    <xsl:param name="fontFamily"/>
    <xsl:param name="fontWeight"/>
    <xsl:param name="fontStyle"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="currencyFormat"/>
    <xsl:param name="currencyFormatType"/>
    <xsl:param name="currencySign"/>
    <xsl:param name="isNoCurrenctFormat2SpecialCondition"/>    
    <xsl:param name="letterSpacing"/>

    <xsl:variable name="updatedYvalue">
      <xsl:choose>
        <xsl:when test="$currencyFormat = 'usa' and $currencySign = '$' and ($currencyFormatType = '3' or $currencyFormatType = '5')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>
        <xsl:when test="$currencyFormat != '' and $currencySign = '£' and ($currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>
        <xsl:when test="$currencyFormat != '' and $currencySign = '￥' and ($currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>
        <xsl:when test="$currencyFormat != '' and $currencySign = '￥' and ($currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>   
        <xsl:when test="$currencyFormat != '' and $currencySign = '￦' and ($currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>       
        <xsl:when test="$currencyFormat != '' and $currencySign = '€' and ($currencyFormatType = '1' or $currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>        
        <xsl:when test="$currencyFormat != '' and $currencySign = '₹' and ($currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>        
        <xsl:when test="$currencyFormat != '' and $currencySign = '₫' and ($currencyFormatType = '1' or $currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>     
        <xsl:when test="$currencyFormat != '' and $currencySign = '₺' and ($currencyFormatType = '1' or $currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>   
        <xsl:when test="$currencyFormat = 'euro' and $currencySign = '$' and ($currencyFormatType = '1' or $currencyFormatType = '3')">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>  
        <xsl:when test="$currencyFormat = '' and $currencySign = '' and $currencyFormatType != ''">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>  
        <xsl:when test="$currencyFormat = 'usa' and $currencySign = '&#160;' and $currencyFormatType != '2'">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>  
        <xsl:when test="$text_decoration = 'overline' and $currencyFormat = '' and $currencySign = '' and $currencyFormatType = ''">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when> 
        <xsl:when test="$text_decoration = 'overline' and $currencyFormat = 'euro' and $currencySign = '&#160;' and ($currencyFormatType = '1' or $currencyFormatType = '8' or $currencyFormatType = '9' )">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>
        <xsl:when test="$isNoCurrenctFormat2SpecialCondition = 'true'">
          <xsl:value-of  select="$tspanY + 4"/>
        </xsl:when>  
        <xsl:otherwise>
          <xsl:value-of  select="$tspanY - 3"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
   
    <xsl:element name="svg:tspan">
      <xsl:attribute name="x">
        <xsl:value-of select="$tspanX"/>
      </xsl:attribute>
      <xsl:attribute name="y">
        <xsl:if test="$text_decoration = 'underline'">
          <xsl:value-of select="$tspanY"/>
        </xsl:if>
        <xsl:if test="$text_decoration = 'overline'">
          <xsl:value-of select="$updatedYvalue - $lineHeight"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="text-decoration">
        <xsl:value-of select="'underline'"/>
      </xsl:attribute>
      <xsl:attribute name="style">
        <xsl:value-of select="'stroke-width: 1;'"/>
      </xsl:attribute>
      <xsl:call-template name="generateSpaces">
        <xsl:with-param name="textWidth" select="$textWidth"/>
        <xsl:with-param name="counter" select="$counter"/>
        <xsl:with-param name="spaceString" select="'&#160;'"/>
        <xsl:with-param name="fontFamily" select="$fontFamily"/>
        <xsl:with-param name="fontWeight" select="$fontWeight"/>
        <xsl:with-param name="fontStyle" select="$fontStyle"/>
        <xsl:with-param name="fontSize" select="$fontSize"/>
        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

      </xsl:call-template>
    </xsl:element>
  </xsl:template>
  <xsl:template name="generateSpaces">
    <xsl:param name="textWidth"/>
    <xsl:param name="counter"/>
    <xsl:param name="spaceString"/>
    <xsl:param name="fontFamily"/>
    <xsl:param name="fontWeight"/>
    <xsl:param name="fontStyle"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="letterSpacing"/>

    <xsl:if test="$counter &gt; 0 and (dgext:getTextWidth(concat('',$letterSpacing,''),$spaceString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) &lt; $textWidth">
      <xsl:call-template name="generateSpaces">
        <xsl:with-param name="textWidth" select="$textWidth"/>
        <xsl:with-param name="counter" select="$counter - 1"/>
        <xsl:with-param name="spaceString" select="concat($spaceString,'&#160;')"/>
        <xsl:with-param name="fontFamily" select="$fontFamily"/>
        <xsl:with-param name="fontWeight" select="$fontWeight"/>
        <xsl:with-param name="fontStyle" select="$fontStyle"/>
        <xsl:with-param name="fontSize" select="$fontSize"/>
        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$counter = 0 or (dgext:getTextWidth(concat('',$letterSpacing,''),$spaceString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) &gt; $textWidth  or (dgext:getTextWidth(concat('',$letterSpacing,''),$spaceString, $fontFamily, $fontWeight, $fontStyle, $fontSize)) = $textWidth">
      <xsl:value-of select="$spaceString"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="slice_text">
	<xsl:param name="textField"/>
	<xsl:param name="position"/>
	<xsl:param name="finalText"/>
	<xsl:param name="fontFamily"/>
	<xsl:param name="fontWeight"/>
	<xsl:param name="fontStyle"/>
	<xsl:param name="fontSize"/>
	<xsl:param name="textWidth"/>
  <xsl:param name="letterSpacing"/>

  <xsl:choose> 
  <xsl:when test="$textWidth >= dgext:getTextWidth(concat('',$letterSpacing,''),$textField, $fontFamily , $fontWeight , $fontStyle, $fontSize)">
  <xsl:value-of select="$textField"/>
  </xsl:when>
		<xsl:when test="dgext:getTextWidth(concat('',$letterSpacing,''),concat($finalText,'V'), $fontFamily , $fontWeight , $fontStyle, $fontSize) >= $textWidth  and ($finalText != '')">
			<xsl:value-of select="$finalText"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="slice_text">
				<xsl:with-param name="textField" select="$textField"/>
				<xsl:with-param name="position" select="$position +1"/>
				<xsl:with-param name="finalText" select="substring($textField, 0, $position +1)"/>
				<xsl:with-param name="fontFamily" select="$fontFamily"/>
				<xsl:with-param name="fontWeight" select="$fontWeight"/>
				<xsl:with-param name="fontStyle" select="$fontStyle"/>
				<xsl:with-param name="fontSize" select="$fontSize"/>
				<xsl:with-param name="textWidth" select="$textWidth"/>
        <xsl:with-param name="letterSpacing" select="$letterSpacing"/>

			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template name="getTextWithoutSliced">
<xsl:param name="textField"/>
<xsl:value-of select="$textField"/>
</xsl:template><xsl:template name="fit_text">
	<xsl:param name="productFieldValue"/>
	<xsl:param name="textAnchor"/>
	<xsl:param name="textWidth"/>
	<xsl:param name="textHeight"/>
	<xsl:param name="lineHeight"/>
	<xsl:param name="textLineHeight"/>
	<xsl:param name="fontFamily"/>
	<xsl:param name="fontStyle"/>
	<xsl:param name="fontWeight"/>
	<xsl:param name="fontSize"/>
	<xsl:param name="tspanX"/>
	<xsl:param name="tspanY"/>
	<xsl:param name="currencySign"/>
	<xsl:param name="currencyPosition"/>
	<xsl:param name="currencyFormat"/>
	<xsl:param name="currencyFormatType"/>
	<xsl:param name="currencyCode"/>
	<xsl:param name="xmlSpace" />
	<xsl:param name="style"/>
	<xsl:param name="textRendering"/>
	<xsl:param name="textVertAlign"/>
	<xsl:param name="zeroformatEnabled"/>
	<xsl:param name="text_decoration_overline"/>
	<xsl:param name="text_decoration_underline"/>
	<xsl:param name="text_decoration_strikethrough"/>
	<xsl:param name="textFitMin"/>
	<xsl:param name="textFitMax"/>
	<xsl:param name="isToApplyUpperCase"/>
	<xsl:param name="isToApplyLowerCase"/>
	<xsl:param name="letterSpacing"/>
	<xsl:param name="customCurrencyFormatName"/>
	<xsl:param name="customCurrencyThousandSeparator"/>
	<xsl:param name="currencySignDisplacementRatioWithFontSizeX"/>
	<xsl:param name="currencySignDisplacementRatioWithFontSizeY"/>
	<xsl:param name="currencyIsDecimalSeperatorVisible"/>
	<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX"/>
	<xsl:param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY"/>
	<xsl:param name="currencyIsDecimalPortionVisible"/>
	<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeX"/>
	<xsl:param name="currencyDecimalPortionDisplacementRatioWithFontSizeY"/>
	<xsl:param name="isCustomCurrencyFormat"/>
	<xsl:param name="currencySizeRatioWithFontSize"/>
	<xsl:param name="currencyDecimalSeperatorSizeRatioWithFontSize"/>
	<xsl:param name="currencyDecimalPortionSizeRatioWithFontSize"/>
  <xsl:param name="isSplitting"/>
	<xsl:param name="splitBy"/>

    <xsl:variable name="addedSlashnForSplit">
      <xsl:choose>
        <xsl:when test="$isSplitting = 'true'">
          <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="$productFieldValue" />
            <xsl:with-param name="replace" select="$splitBy" />
            <xsl:with-param name="by" select="'\n'" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$productFieldValue" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
 
    <xsl:variable name="productFieldWithBackSlashN">
	        <xsl:call-template name="replace-backslash-n">
	            <xsl:with-param name="text" select="$addedSlashnForSplit" />
	            <xsl:with-param name="accum" select="''" />
	        </xsl:call-template>
	  </xsl:variable>

	<xsl:variable name="commaValidation">
		<xsl:value-of select="translate($productFieldWithBackSlashN, ',', '.')"/>
	</xsl:variable>

	<xsl:variable name="currencyfiedString">
		<xsl:choose>
			<xsl:when test="number($productFieldWithBackSlashN) = $productFieldWithBackSlashN">
				<xsl:call-template name="addCurrencySign">
					<xsl:with-param name="productFieldValue" select="$commaValidation"/>
					<xsl:with-param name="currencySign" select="$currencySign"/>
					<xsl:with-param name="currencyPosition" select="$currencyPosition"/>
					<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
					<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
					<xsl:with-param name="currencyCode" select="$currencyCode"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="number($commaValidation) = $commaValidation">
				<xsl:call-template name="addCurrencySign">
					<xsl:with-param name="productFieldValue" select="$commaValidation"/>
					<xsl:with-param name="currencySign" select="$currencySign"/>
					<xsl:with-param name="currencyPosition" select="$currencyPosition"/>
					<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
					<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
					<xsl:with-param name="currencyCode" select="$currencyCode"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$isToApplyUpperCase = 'true'">
						<xsl:value-of  select="translate($productFieldWithBackSlashN,$smallcase,$uppercase)"/>
					</xsl:when>
					<xsl:when test="$isToApplyLowerCase = 'true'">
						<xsl:value-of  select="translate($productFieldWithBackSlashN,$uppercase,$smallcase)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$productFieldWithBackSlashN"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="(dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) &gt;= $textWidth) or (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) &lt; $textWidth)">
			<xsl:variable name="new_font_size_withoutMinMaxCheck">
				<xsl:value-of select="floor($fontSize * $textWidth div (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) + 1))"/>
			</xsl:variable>

			<xsl:variable name="new_font_size">
				<xsl:choose>
					<xsl:when test="($textFitMin != '') and ($new_font_size_withoutMinMaxCheck &lt; $textFitMin)">
						<xsl:value-of select="$textFitMin"/>
					</xsl:when>
					<xsl:when test="($textFitMax != '') and ($new_font_size_withoutMinMaxCheck &gt; $textFitMax)">
						<xsl:value-of select="$textFitMax"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$new_font_size_withoutMinMaxCheck"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="font_reduction_ratio">
				<xsl:value-of select="$fontSize div $new_font_size"/>
			</xsl:variable>
			<xsl:variable name="verticalAlignOffset">
				<xsl:if test="$textVertAlign = 'middle'">
					<xsl:value-of select="(($textHeight - (($lineHeight div $font_reduction_ratio) * 1)) div 2) + ((($lineHeight div $font_reduction_ratio) - ($textLineHeight div $font_reduction_ratio)) div 2)"/>
				</xsl:if>
				<xsl:if test="$textVertAlign = 'bottom'">
					<xsl:value-of select="(($textHeight - ($lineHeight div $font_reduction_ratio) * 1)) + ((($lineHeight div $font_reduction_ratio) - ($textLineHeight div $font_reduction_ratio)) div 2)"/>
				</xsl:if>
				<xsl:if test="$textVertAlign = 'top'">
					<xsl:value-of select="0"/>
				</xsl:if>
			</xsl:variable>
			<xsl:element name="svg:text">
				<xsl:attribute name="xml:space">
					<xsl:value-of select="string($xmlSpace)"/>
				</xsl:attribute>
				<xsl:attribute name="letter-spacing">
					<xsl:value-of select="concat($letterSpacing,'em')"/>
				</xsl:attribute>
				<xsl:attribute name="font-size">
					<xsl:value-of select="$new_font_size"/>
				</xsl:attribute>
				<xsl:attribute name="font-style">
					<xsl:choose>
						<xsl:when test="$fontStyle = 0.20f">
							<xsl:value-of  select="'italic'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of  select="'normal'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="font-weight">
					<xsl:choose>
						<xsl:when test="$fontWeight = 2.0f">
							<xsl:value-of  select="'bold'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of  select="'normal'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="font-family">
					<xsl:value-of select="$fontFamily"/>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:value-of select="string($style)"/>
				</xsl:attribute>
				<xsl:attribute name="text-rendering">
					<xsl:value-of select="$textRendering"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="not($currencyFormatType ='') or ($isCustomCurrencyFormat = 'true' and ((number($productFieldValue) = $productFieldValue) or (number($commaValidation) = $commaValidation)))">
						<xsl:call-template name="additionalCurrencyFormatting">
							<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
							<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
							<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
							<xsl:with-param name="currencySign" select="$currencySign"/>
							<xsl:with-param name="textAnchor" select="$textAnchor"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontSize" select="$new_font_size"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="lineHeight" select="($new_font_size * 1.13) + 4"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
							<xsl:with-param name="noOfLine" select="0"/>
							<xsl:with-param name="tspanX" select="$tspanX"/>
							<xsl:with-param name="tspanY" select="(-($textHeight div 2) + (($new_font_size * ($lineHeight div $textLineHeight) * 1.13) * ((1 - 0.222) div ($lineHeight div $textLineHeight)))) + $verticalAlignOffset"/>
							<xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
							<xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
							<xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
							<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
							<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
							<xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"></xsl:with-param>
							<xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"></xsl:with-param>
							<xsl:with-param name="currencyPosition" select="$currencyPosition"></xsl:with-param>
							<xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"></xsl:with-param>
							<xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"></xsl:with-param>
							<xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"></xsl:with-param>
							<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"></xsl:with-param>
							<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"></xsl:with-param>
							<xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"></xsl:with-param>
							<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"></xsl:with-param>
							<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"></xsl:with-param>
							<xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"></xsl:with-param>
							<xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"></xsl:with-param>
							<xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"></xsl:with-param>
							<xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"></xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
				       
                  <xsl:if test="string-length(normalize-space($currencyfiedString)) &gt; 0">
								    <xsl:variable name="linesElementOfTextFit">
									  <xsl:call-template name="split-and-wraplines">
										<xsl:with-param name="text" select="$currencyfiedString"/>
										<xsl:with-param name="textWidth" select="$textWidth"/>
										<xsl:with-param name="textHeight" select="$textHeight"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontSize" select="$new_font_size"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
										<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
										<xsl:with-param name="tspanX" select="$tspanX"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="linesArrayOfTextFit" select="ext:node-set($linesElementOfTextFit)/*"/>
								<xsl:variable name="calculatedLines" select="floor($textHeight div $new_font_size)"/>
								<xsl:variable name="maxLinesAllowedOfTextFit">
								<xsl:choose>
									<xsl:when test="$calculatedLines &lt; 1">1</xsl:when>
									<xsl:otherwise>
									<xsl:value-of select="$calculatedLines"/>
									</xsl:otherwise>
								</xsl:choose>
								</xsl:variable>
								<xsl:variable name="linesToRender">
									<xsl:choose>
										<xsl:when test="count($linesArrayOfTextFit) &gt; $maxLinesAllowedOfTextFit">
											<xsl:value-of select="$maxLinesAllowedOfTextFit"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="count($linesArrayOfTextFit)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

                  <xsl:variable name="verticalAlignOffsetForFit">
                      <xsl:choose>
                          <xsl:when test="$textVertAlign = 'middle'">
                              <xsl:value-of select="(floor($lineHeight) - ($new_font_size* $linesToRender)) div 2"/>
                          </xsl:when>
                          <xsl:when test="$textVertAlign = 'bottom'">
                              <xsl:value-of select="(floor($lineHeight) - ($new_font_size* $linesToRender))"/>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:value-of select="0"/>
                          </xsl:otherwise>
                      </xsl:choose>
                  </xsl:variable>
								<xsl:for-each select="$linesArrayOfTextFit[position() &lt;= $linesToRender]">
									<svg:tspan x="{$tspanX}"  >
										<xsl:attribute name="style">
											<xsl:value-of select="'white-space: pre'"/>
										</xsl:attribute>
											<xsl:attribute name="y">
											<xsl:choose>
												<!-- Multiple lines => use verticalAlignOffsetForFit -->
												<xsl:when test="count($linesArrayOfTextFit) &gt; 1">
												<xsl:value-of select="($tspanY + ($new_font_size * (position() - 1)) + $verticalAlignOffsetForFit) - ($fontSize - $new_font_size)"/>
												</xsl:when>
												<!-- Single line => use verticalAlignOffset -->
												<xsl:otherwise>
												<!-- <xsl:value-of select="($tspanY + ($new_font_size * (position() - 1)) + $verticalAlignOffset) - ($fontSize - $new_font_size)"/> -->
									            <xsl:value-of select="(-($textHeight div 2) + (($new_font_size * ($lineHeight div $textLineHeight) * 1.13) * ((1 - 0.222) div ($lineHeight div $textLineHeight)))) + $verticalAlignOffset"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>
											<xsl:if test="  $text_decoration_strikethrough = 'strikethrough' or $text_decoration_overline = 'overline' or $text_decoration_underline = 'underline'">
												<xsl:attribute name="text-decoration">
												<xsl:variable name="decorations">
												<xsl:if test="$text_decoration_overline = 'overline'">
													<xsl:text>overline </xsl:text>
												</xsl:if>
												<xsl:if test="$text_decoration_underline = 'underline'">
													<xsl:text>underline </xsl:text>
												</xsl:if>
												<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
													<xsl:text>line-through</xsl:text>
												</xsl:if>
												</xsl:variable>
												<xsl:value-of select="normalize-space($decorations)"/>
											   </xsl:attribute>
											</xsl:if> 
										<xsl:attribute name="text-anchor">
											<xsl:value-of select="$textAnchor"/>
										</xsl:attribute>
										<xsl:value-of select="."/>
									</svg:tspan>
								</xsl:for-each>
					        </xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
	         <xsl:variable name="new_font_size_withoutMinMaxCheck">
				<xsl:value-of select="floor($fontSize * $textWidth div (dgext:getTextWidth(concat('',$letterSpacing,''),$currencyfiedString, $fontFamily , $fontWeight , $fontStyle, number($fontSize)) + 1))"/>
			</xsl:variable>
			<xsl:variable name="new_font_size">
				<xsl:choose>
					<xsl:when test="($textFitMin != '') and ($new_font_size_withoutMinMaxCheck &lt; $textFitMin)">
						<xsl:value-of select="$textFitMin"/>
					</xsl:when>
					<xsl:when test="($textFitMax != '') and ($new_font_size_withoutMinMaxCheck &gt; $textFitMax)">
						<xsl:value-of select="$textFitMax"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$new_font_size_withoutMinMaxCheck"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="verticalAlignOffset">
				<xsl:if test="$textVertAlign = 'middle'">
					<xsl:value-of select="(($textHeight - ($lineHeight * 1)) div 2) + (($lineHeight - $textLineHeight) div 2)"/>
				</xsl:if>
				<xsl:if test="$textVertAlign = 'bottom'">
					<xsl:value-of select="(($textHeight - $lineHeight * 1)) + (($lineHeight - $textLineHeight) div 2)"/>
				</xsl:if>
				<xsl:if test="$textVertAlign = 'top'">
					<xsl:value-of select="0"/>
				</xsl:if>
			</xsl:variable>

			<xsl:element name="svg:text">
				<xsl:attribute name="xml:space">
					<xsl:value-of select="string($xmlSpace)"/>
				</xsl:attribute>
				<xsl:attribute name="letter-spacing">
					<xsl:value-of select="concat($letterSpacing,'em')"/>
				</xsl:attribute>
				<xsl:attribute name="font-size">
					<xsl:value-of select="$fontSize"/>
				</xsl:attribute>
				<xsl:attribute name="font-style">
					<xsl:choose>
						<xsl:when test="$fontStyle = 0.20f">
							<xsl:value-of  select="'italic'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of  select="'normal'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="font-weight">
					<xsl:choose>
						<xsl:when test="$fontWeight = 2.0f">
							<xsl:value-of  select="'bold'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of  select="'normal'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="font-family">
					<xsl:value-of select="$fontFamily"/>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:value-of select="string($style)"/>
				</xsl:attribute>
				<xsl:attribute name="text-rendering">
					<xsl:value-of select="$textRendering"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="not($currencyFormatType ='')">
						<xsl:call-template name="additionalCurrencyFormatting">
							<xsl:with-param name="currencyfiedString" select="$currencyfiedString"/>
							<xsl:with-param name="currencyFormat" select="$currencyFormat"/>
							<xsl:with-param name="currencyFormatType" select="$currencyFormatType"/>
							<xsl:with-param name="currencySign" select="$currencySign"/>
							<xsl:with-param name="textAnchor" select="$textAnchor"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="lineHeight" select="$lineHeight"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
							<xsl:with-param name="noOfLine" select="0"/>
							<xsl:with-param name="tspanX" select="$tspanX"/>
							<xsl:with-param name="tspanY" select="$tspanY"/>
							<xsl:with-param name="text_decoration_overline" select="$text_decoration_overline"/>
							<xsl:with-param name="text_decoration_underline" select="$text_decoration_underline"/>
							<xsl:with-param name="text_decoration_strikethrough" select="$text_decoration_strikethrough"/>
							<xsl:with-param name="zeroformatEnabled" select="$zeroformatEnabled"/>
							<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
							<xsl:with-param name="customCurrencyFormatName" select="$customCurrencyFormatName"></xsl:with-param>
							<xsl:with-param name="customCurrencyThousandSeparator" select="$customCurrencyThousandSeparator"></xsl:with-param>
							<xsl:with-param name="currencyPosition" select="$currencyPosition"></xsl:with-param>
							<xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="$currencySignDisplacementRatioWithFontSizeX"></xsl:with-param>
							<xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="$currencySignDisplacementRatioWithFontSizeY"></xsl:with-param>
							<xsl:with-param name="currencyIsDecimalSeperatorVisible" select="$currencyIsDecimalSeperatorVisible"></xsl:with-param>
							<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeX"></xsl:with-param>
							<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="$currencyDecimalSeperatorDisplacementRatioWithFontSizeY"></xsl:with-param>
							<xsl:with-param name="currencyIsDecimalPortionVisible" select="$currencyIsDecimalPortionVisible"></xsl:with-param>
							<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="$currencyDecimalPortionDisplacementRatioWithFontSizeX"></xsl:with-param>
							<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="$currencyDecimalPortionDisplacementRatioWithFontSizeY"></xsl:with-param>
							<xsl:with-param name="isCustomCurrencyFormat" select="$isCustomCurrencyFormat"></xsl:with-param>
							<xsl:with-param name="currencySizeRatioWithFontSize" select="$currencySizeRatioWithFontSize"></xsl:with-param>
							<xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="$currencyDecimalSeperatorSizeRatioWithFontSize"></xsl:with-param>
							<xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="$currencyDecimalPortionSizeRatioWithFontSize"></xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
                  <xsl:if test="string-length(normalize-space($currencyfiedString)) &gt; 0">
								    <xsl:variable name="linesElementOfTextFit">
									  <xsl:call-template name="split-and-wraplines">
										<xsl:with-param name="text" select="$currencyfiedString"/>
										<xsl:with-param name="textWidth" select="$textWidth"/>
										<xsl:with-param name="textHeight" select="$textHeight"/>
										<xsl:with-param name="lineHeight" select="$lineHeight"/>
										<xsl:with-param name="fontFamily" select="$fontFamily"/>
										<xsl:with-param name="fontStyle" select="$fontStyle"/>
										<xsl:with-param name="fontWeight" select="$fontWeight"/>
										<xsl:with-param name="fontSize" select="$new_font_size"/>
										<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
										<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
										<xsl:with-param name="tspanX" select="$tspanX"/>
										<xsl:with-param name="tspanY" select="$tspanY"/>
										<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="linesArrayOfTextFit" select="ext:node-set($linesElementOfTextFit)/*"/>
								<xsl:variable name="maxLinesAllowedOfTextFit" select="floor($textHeight div $new_font_size)"/>
								<xsl:variable name="linesToRender">
									<xsl:choose>
										<xsl:when test="count($linesArrayOfTextFit) &gt; $maxLinesAllowedOfTextFit">
											<xsl:value-of select="$maxLinesAllowedOfTextFit"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="count($linesArrayOfTextFit)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>

                    <xsl:variable name="verticalAlignOffsetForFit">
                      <xsl:choose>
                          <xsl:when test="$textVertAlign = 'middle'">
                              <xsl:value-of select="($lineHeight - ($new_font_size* $linesToRender)) div 2"/>
                          </xsl:when>
                          <xsl:when test="$textVertAlign = 'bottom'">
                              <xsl:value-of select="($lineHeight - ($new_font_size* $linesToRender))"/>
                          </xsl:when>
                          <xsl:otherwise>
                              <xsl:value-of select="0"/>
                          </xsl:otherwise>
                      </xsl:choose>
                  </xsl:variable>

								<xsl:for-each select="$linesArrayOfTextFit[position() &lt;= $linesToRender]">
									<svg:tspan x="{$tspanX}"  >
										<xsl:attribute name="style">
											<xsl:value-of select="'white-space: pre'"/>
										</xsl:attribute>  

                    <xsl:attribute name="y">
											<xsl:choose>
												<!-- Multiple lines => use verticalAlignOffsetForFit -->
												<xsl:when test="count($linesArrayOfTextFit) &gt; 1">
												<xsl:value-of select="($tspanY + ($new_font_size * (position() - 1)) + $verticalAlignOffsetForFit) - ($fontSize - $new_font_size)"/>
												</xsl:when>
												<!-- Single line => use tspanY -->
												<xsl:otherwise>
												<xsl:value-of select="$tspanY"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:attribute>

											<xsl:if test="  $text_decoration_strikethrough = 'strikethrough' or $text_decoration_overline = 'overline' or $text_decoration_underline = 'underline'">
												<xsl:attribute name="text-decoration">
												<xsl:variable name="decorations">
												<xsl:if test="$text_decoration_overline = 'overline'">
													<xsl:text>overline </xsl:text>
												</xsl:if>
												<xsl:if test="$text_decoration_underline = 'underline'">
													<xsl:text>underline </xsl:text>
												</xsl:if>
												<xsl:if test="$text_decoration_strikethrough = 'strikethrough'">
													<xsl:text>line-through</xsl:text>
												</xsl:if>
												</xsl:variable>
												<xsl:value-of select="normalize-space($decorations)"/>
											</xsl:attribute>
											</xsl:if> 
										<xsl:attribute name="text-anchor">
											<xsl:value-of select="$textAnchor"/>
										</xsl:attribute>
										<xsl:value-of select="."/>
									</svg:tspan>
								</xsl:for-each>
							</xsl:if>

					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template><xsl:template name="roundOffTemplate">
      <xsl:param name="roundOffData" as="xs:string"/>
      <xsl:param name="roundFormat" as="xs:string"/>
      <xsl:param name="calcDivFormat" as="xs:string"/>
      <xsl:param name="formatValue" as="xs:string"/>

        <xsl:variable name="decimalField">
            <xsl:if test="$calcDivFormat = '1f' or $calcDivFormat = '1f_' ">
                <xsl:value-of select="10"/>
            </xsl:if>
            <xsl:if test="$calcDivFormat = '2f' or $calcDivFormat = '2f_' ">
                <xsl:value-of select="100"/>
            </xsl:if>
            <xsl:if test="$calcDivFormat = '3f' or $calcDivFormat = '3f_'">
                <xsl:value-of select="1000"/>
            </xsl:if>
        </xsl:variable>

      <xsl:choose>
        <xsl:when test="$roundFormat = 'default'">
            <xsl:if test="$calcDivFormat = '3f' or  $calcDivFormat = '2f'  or  $calcDivFormat = '1f'">
              <xsl:value-of select="format-number($roundOffData, $formatValue)"/>
            </xsl:if>

            <xsl:if test="$calcDivFormat = '3f_' or  $calcDivFormat = '2f_'  or  $calcDivFormat = '1f_'">
                <xsl:value-of select="translate(round($roundOffData * $decimalField) div $decimalField, '.', ',')"/>
            </xsl:if>

        </xsl:when>

        <xsl:when test="$roundFormat = 'round'">
            <xsl:if test="$calcDivFormat = '3f' or  $calcDivFormat = '2f'  or  $calcDivFormat = '1f'">

              <xsl:variable name="formatRoundVal">
                  <xsl:value-of select="round($roundOffData * $decimalField) div $decimalField"/>
              </xsl:variable>

            <xsl:value-of select="format-number($formatRoundVal, $formatValue)"/>

            </xsl:if>

            <xsl:if test="$calcDivFormat = '3f_' or  $calcDivFormat = '2f_'  or  $calcDivFormat = '1f_'">
                <xsl:value-of select="translate(round($roundOffData * $decimalField) div $decimalField, '.', ',')"/>
            </xsl:if>

        </xsl:when>
        <xsl:when test="$roundFormat = 'floor'">
            <xsl:if test="$calcDivFormat = '3f' or  $calcDivFormat = '2f'  or  $calcDivFormat = '1f'">

            <xsl:variable name="formatRoundVal">
                <xsl:value-of select="floor($roundOffData * $decimalField) div $decimalField"/> 
            </xsl:variable>

            <xsl:value-of select="format-number($formatRoundVal, $formatValue)"/>

            </xsl:if>
            <xsl:if test="$calcDivFormat = '3f_' or  $calcDivFormat = '2f_'  or  $calcDivFormat = '1f_'">
                <xsl:value-of select="translate(floor($roundOffData * $decimalField) div $decimalField, '.', ',')"/>
            </xsl:if>
        </xsl:when>
        <xsl:when test="$roundFormat = 'ceiling'">
            <xsl:if test="$calcDivFormat = '3f' or  $calcDivFormat = '2f'  or  $calcDivFormat = '1f'">

              <xsl:variable name="formatRoundVal">
                <xsl:value-of select="ceiling($roundOffData * $decimalField) div $decimalField"/> 
              </xsl:variable>

              <xsl:value-of select="format-number($formatRoundVal, $formatValue)"/>

            </xsl:if>
            <xsl:if test="$calcDivFormat = '3f_' or  $calcDivFormat = '2f_'  or  $calcDivFormat = '1f_'">
                <xsl:value-of select="translate(ceiling($roundOffData * $decimalField) div $decimalField, '.', ',')"/>
            </xsl:if>
        </xsl:when>
      </xsl:choose>


    </xsl:template>	<xsl:template name="split-and-wraplines">
		<xsl:param name="text"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="lineIndex"/>
		<xsl:param name="textVertAlign"/>
		<xsl:param name="textLineHeight" />
		<xsl:choose>
			<xsl:when test="contains($text, 'U+000A')">
			
				<xsl:variable name="before" select="substring-before($text, 'U+000A')" />
				<xsl:variable name="after" select="substring-after($text, 'U+000A')" />
			
				<xsl:call-template name="wrapline">
					<xsl:with-param name="line" select="$before"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
					<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
				</xsl:call-template>
			
				<xsl:call-template name="split-and-wraplines">
          <xsl:with-param name="text" select="$after"/>
          <xsl:with-param name="textWidth" select="$textWidth"/>
          <xsl:with-param name="fontFamily" select="$fontFamily"/>
          <xsl:with-param name="fontStyle" select="$fontStyle"/>
          <xsl:with-param name="fontWeight" select="$fontWeight"/>
          <xsl:with-param name="fontSize" select="$fontSize"/>
          <xsl:with-param name="letterSpacing" select="$letterSpacing"/>
          <xsl:with-param name="lineHeight" select="$lineHeight"/>
          <xsl:with-param name="tspanX" select="$tspanX"/>
          <xsl:with-param name="tspanY" select="$tspanY"/>
          <xsl:with-param name="textAnchor" select="$textAnchor"/>
          <xsl:with-param name="lineIndex" select="$lineIndex + 1"/>
          <xsl:with-param name="textVertAlign" select="$textVertAlign"/>
          <xsl:with-param name="textLineHeight" select="$textLineHeight"/>
            </xsl:call-template>
			</xsl:when>
	
			<xsl:otherwise>
				<xsl:call-template name="wrapline">
					<xsl:with-param name="line" select="$text"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
					<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
	<!-- Wraps line into multiple tspans based on width -->
	<xsl:template name="wrapline">
		<xsl:param name="line"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:param name="lineHeight"/>
		<xsl:param name="tspanX"/>
		<xsl:param name="tspanY"/>
		<xsl:param name="textAnchor"/>
		<xsl:param name="lineIndex"/>
		<xsl:param name="textLineHeight" />
		<xsl:param name="textVertAlign"/>
		<xsl:if test="string-length($line) &gt; 0">
			<xsl:variable name="splitPos">
				<xsl:call-template name="binarySearchWidth">
					<xsl:with-param name="text" select="$line"/>
					<xsl:with-param name="low" select="1"/>
					<xsl:with-param name="high" select="string-length($line)"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="textVertAlign" select="$textVertAlign"/>
					<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
				</xsl:call-template>
			</xsl:variable>
			<!-- Print one line -->
			<line>
				<xsl:value-of select="normalize-space(substring($line, 1, $splitPos))"/>
			</line>
			<xsl:variable name="remaining" select="substring($line, $splitPos + 1)"/>
			<xsl:if test="string-length($remaining) &gt; 0">
				<xsl:call-template name="wrapline">
					<xsl:with-param name="line" select="$remaining"/>
					<xsl:with-param name="textWidth" select="$textWidth"/>
					<xsl:with-param name="fontFamily" select="$fontFamily"/>
					<xsl:with-param name="fontStyle" select="$fontStyle"/>
					<xsl:with-param name="fontWeight" select="$fontWeight"/>
					<xsl:with-param name="fontSize" select="$fontSize"/>
					<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
					<xsl:with-param name="lineHeight" select="$lineHeight"/>
					<xsl:with-param name="tspanX" select="$tspanX"/>
					<xsl:with-param name="tspanY" select="$tspanY"/>
					<xsl:with-param name="textAnchor" select="$textAnchor"/>
					<xsl:with-param name="lineIndex" select="$lineIndex + 1"/>
					<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- Binary search to find max fitting characters -->
	<xsl:template name="binarySearchWidth">
		<xsl:param name="text"/>
		<xsl:param name="low"/>
		<xsl:param name="high"/>
		<xsl:param name="textWidth"/>
		<xsl:param name="fontFamily"/>
		<xsl:param name="fontStyle"/>
		<xsl:param name="fontWeight"/>
		<xsl:param name="fontSize"/>
		<xsl:param name="letterSpacing"/>
		<xsl:param name="textLineHeight" />
		<xsl:choose>
			<xsl:when test="$low &gt; $high">
				<xsl:value-of select="$low - 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="mid" select="floor(($low + $high) div 2)"/>
				<xsl:variable name="substring" select="substring($text, 1, $mid)"/>
				<xsl:variable name="width" select="dgext:getTextWidth($letterSpacing, $substring, $fontFamily, $fontWeight, $fontStyle, $fontSize)"/>
				<xsl:choose>
					<xsl:when test="$width &lt;= $textWidth">
						<xsl:call-template name="binarySearchWidth">
							<xsl:with-param name="text" select="$text"/>
							<xsl:with-param name="low" select="$mid + 1"/>
							<xsl:with-param name="high" select="$high"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="binarySearchWidth">
							<xsl:with-param name="text" select="$text"/>
							<xsl:with-param name="low" select="$low"/>
							<xsl:with-param name="high" select="$mid - 1"/>
							<xsl:with-param name="textWidth" select="$textWidth"/>
							<xsl:with-param name="fontFamily" select="$fontFamily"/>
							<xsl:with-param name="fontStyle" select="$fontStyle"/>
							<xsl:with-param name="fontWeight" select="$fontWeight"/>
							<xsl:with-param name="fontSize" select="$fontSize"/>
							<xsl:with-param name="letterSpacing" select="$letterSpacing"/>
							<xsl:with-param name="textLineHeight" select="$textLineHeight"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    <xsl:template name="replace-backslash-n-with-flag">
      <xsl:param name="text"/>
      <xsl:param name="search"/>
      <xsl:param name="replace"/>
      <xsl:choose>
        <xsl:when test="contains($text, $search)">
            <xsl:value-of select="substring-before($text, $search)"/>
            <xsl:value-of select="$replace"/>
          <xsl:call-template name="replace-backslash-n-with-flag">
          <xsl:with-param name="text" select="substring-after($text, $search)"/>
          <xsl:with-param name="search" select="$search"/>
          <xsl:with-param name="replace" select="$replace"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
		</xsl:template>
      <xsl:template name="string-replace-all">
        <xsl:param name="text" />
        <xsl:param name="replace" />
        <xsl:param name="by" />
        <xsl:choose>
          <xsl:when test="contains($text, $replace)">
            <!-- Perform recursive replacement -->
            <xsl:value-of select="substring-before($text, $replace)" />
            <xsl:value-of select="$by" />
            <xsl:call-template name="string-replace-all">
              <xsl:with-param name="text" select="substring-after($text, $replace)" />
              <xsl:with-param name="replace" select="$replace" />
              <xsl:with-param name="by" select="$by" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$text" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:template>
    <xsl:template name="logoTemplate">
              <xsl:param name="top"/>
              <xsl:param name="bottom"/>
              <xsl:param name="left"/>
              <xsl:param name="right"/>
              <xsl:param name="topIndex"/>
              <xsl:param name="bottomIndex"/>
              <xsl:param name="leftIndex"/>
              <xsl:param name="rightIndex"/>
              <xsl:param name="width"/>
              <xsl:param name="height"/>
              <xsl:param name="image"/>
              <xsl:param name="angle"/>
              <!-- Block container with conditional attributes -->
              <fo:block-container reference-orientation="{$angle}" 
                    position="absolute" 
                    width="{$width}px" 
                    height="{$height}px">
                <!-- Conditionally applying the top attribute -->
                <xsl:if test="$topIndex = true()">
                  <xsl:attribute name="top">
                    <xsl:value-of select="$top"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- Conditionally applying the bottom attribute -->
                <xsl:if test="$bottomIndex = true()">
                  <xsl:attribute name="bottom">
                    <xsl:value-of select="$bottom"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- Conditionally applying the left attribute -->
                <xsl:if test="$leftIndex = true()">
                  <xsl:attribute name="left">
                    <xsl:value-of select="$left"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- Conditionally applying the right attribute -->
                <xsl:if test="$rightIndex = true()">
                  <xsl:attribute name="right">
                    <xsl:value-of select="$right"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- Inner block-container for the image background -->
                <fo:block-container background-image="{$image}" background-repeat="no-repeat">
                  <fo:block line-height="0.9">
                    <fo:instream-foreign-object>
                      <svg width="0" height="0"
                        xmlns="http://www.w3.org/2000/svg">
                      </svg>
                    </fo:instream-foreign-object>
                  </fo:block>
                </fo:block-container>
              </fo:block-container>
            </xsl:template></xsl:stylesheet>