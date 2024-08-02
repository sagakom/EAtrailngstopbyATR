//+------------------------------------------------------------------+
//|                                         TRAILINGSTOPBYATR.mq5 |
//|                                  Copyright 2024, Kursustrading.my.id |
//|                                             https://eawb.my.id |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

int handleATR = INVALID_HANDLE;
double dataATR[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
   handleATR = iATR(_Symbol,_Period,14);
   if (handleATR == INVALID_HANDLE){
      Print("INVALID IND ATR HANDLE. REVERTING NOW");
      return (INIT_FAILED);
   }
   ArraySetAsSeries(dataATR,true);
   
   obj_Trade.SetExpertMagicNumber(123);
   
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   obj_Trade.Buy(0.01);
   obj_Trade.Sell(0.01);

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   
   if (CopyBuffer(handleATR,0,0,3,dataATR) < 3){
      Print("NOT ENOUGH DATA FOR FURTHER CALC'S. REVERTING");
      return;
   }
   
   if (dataATR[0] > 0){
   
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      double buy_trail = Bid - NormalizeDouble(dataATR[0],_Digits);
      double sell_trail = Ask + NormalizeDouble(dataATR[0],_Digits);

      for (int i=PositionsTotal()-1; i>=0; i--){
         ulong ticket = PositionGetTicket(i);
         if (ticket > 0){
            if (PositionSelectByTicket(ticket)){
               string symb = PositionGetString(POSITION_SYMBOL);
               long type = PositionGetInteger(POSITION_TYPE);
               ulong magic = PositionGetInteger(POSITION_MAGIC);
               double open_p = PositionGetDouble(POSITION_PRICE_OPEN);
               double sl = PositionGetDouble(POSITION_SL);
               double tp = PositionGetDouble(POSITION_TP);
               if (symb == _Symbol && magic == 123){
                  if (type == POSITION_TYPE_BUY){
                     if (buy_trail > open_p && (sl == 0 || buy_trail > sl)){ // 0.68 > 0
                        obj_Trade.PositionModify(ticket,buy_trail,tp);
                     }
                  }
                  else if (type == POSITION_TYPE_SELL){
                     if (sell_trail < open_p && (sl == 0 || sell_trail < sl)){//0.68 < 0
                        obj_Trade.PositionModify(ticket,sell_trail,tp);
                     }
                  }
               }
            }
         }
      }
   }
   
   
}
//+------------------------------------------------------------------+


TRAILING STOP BY ATR #sourcecode
