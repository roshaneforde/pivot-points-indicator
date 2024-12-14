//+------------------------------------------------------------------+
//|                                                  PivotPoints.mq5 |
//|                                                    Roshane Forde |
//|                                        https://roshaneforde.com/ |
//+------------------------------------------------------------------+
#property copyright "Roshane Forde"
#property link "https://roshaneforde.com/"
#property version "1.04"
#property indicator_chart_window

#property indicator_buffers 2;
#property indicator_plots   2;
#property indicator_type1   DRAW_NONE;

enum YesNo {
  YES,
  NO
};

input int lastSetOfCandles = 120; // Number of candles to draw lines on
input YesNo drawBuyLine = YES; // Draw buy line
input color buyLineColor = clrDodgerBlue; // Buy Line Color
input ENUM_LINE_STYLE buyLineStyle = STYLE_DOT; // Buy Line Style
input int buyLineWidth = 1; // Buy Line Width

input YesNo drawSellLine = YES; // Draw sell line
input color sellLineColor = clrOrangeRed; // Sell line Color
input ENUM_LINE_STYLE sellLineStyle = STYLE_DOT; // Sell Line Style
input int sellLineWidth = 1; // Sell Line Width

// Buffers
double buyLineBuffer[];
double sellLineBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  SetIndexBuffer(0, buyLineBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, sellLineBuffer, INDICATOR_DATA);

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  
  // Only run if new candles are available
  if (rates_total <= prev_calculated) {
    return (rates_total);
  }

  // Number of candles
  int totalCandles = rates_total - lastSetOfCandles;

  for (int i = totalCandles; i < rates_total - 1; i++) {
    drawLines(i, time, open, high, low, close, rates_total);
  }

  return (rates_total);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  removeLines();
}

//+------------------------------------------------------------------+
//| Draw lines                                                      |
//+------------------------------------------------------------------+
void drawLines(int i, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const int rates_total)
{
  // Line prices
  double buyLinePrice = 0;
  double sellLinePrice = 0;

  // Unique name for each line
  string buyLineName = "BuyLine_" + IntegerToString(i);
  string sellLineName = "SellLine_" + IntegerToString(i);

  // Bullish pivot point
  if (open[i - 1] < close[i - 1] && open[i] > close[i]) {
    buyLinePrice = close[i - 1];
  }

  // Bearish pivot point
  if (open[i - 1] > close[i - 1] && open[i] < close[i]) {
    sellLinePrice = close[i - 1];
  }
  
  buyLineBuffer[i] = buyLinePrice;
  sellLineBuffer[i] = sellLinePrice;
  
  // Extend lines to the last candle that close above or below the line
  int endIndex = rates_total - 1;
  
  // Find where the buy line is broken
  if (buyLinePrice > 0) {
    for (int j = i + 1; j < rates_total; j++) {
      if (close[j] > buyLinePrice) {
        endIndex = j;
        break;
      }
    }

    if (drawBuyLine == YES) {
      ObjectCreate(0, buyLineName, OBJ_TREND, 0, time[i - 1], buyLinePrice, time[endIndex], buyLinePrice);
      ObjectSetInteger(0, buyLineName, OBJPROP_COLOR, buyLineColor);
      ObjectSetInteger(0, buyLineName, OBJPROP_WIDTH, buyLineWidth);
      ObjectSetInteger(0, buyLineName, OBJPROP_STYLE, buyLineStyle);
    }
  }

  // Find where the sell line is broken
  endIndex = rates_total - 1;

  if (sellLinePrice > 0) {
    for (int j = i + 1; j < rates_total; j++) {
      if (close[j] < sellLinePrice) {
        endIndex = j;
        break;
      }
    }

    if (drawSellLine == YES) {
      ObjectCreate(0, sellLineName, OBJ_TREND, 0, time[i - 1], sellLinePrice, time[endIndex], sellLinePrice);
      ObjectSetInteger(0, sellLineName, OBJPROP_COLOR, sellLineColor);
      ObjectSetInteger(0, sellLineName, OBJPROP_WIDTH, sellLineWidth);
      ObjectSetInteger(0, sellLineName, OBJPROP_STYLE, sellLineStyle);
    }
  }
}

//+------------------------------------------------------------------+
//| Remove all lines                                                 |
//+------------------------------------------------------------------+
void removeLines()
{
  for (int i = ObjectsTotal(0); i >= 0; i--) {
    string name = ObjectName(0, i);

    if (StringFind(name, "BuyLine_", 0) != -1) {
      ObjectDelete(0, name);
    }

    if (StringFind(name, "SellLine_", 0) != -1) {
      ObjectDelete(0, name);
    }
  }

  if (StringFind( ObjectName(0, 1), "BuyLine_") >= 0) {
    ObjectDelete(0, "BuyLine_1");
  }

  if (StringFind( ObjectName(0, 1), "SellLine_") >= 0) {
    ObjectDelete(0, "SellLine_1");
  }
}
