within ThermoPower.customModel.Interfaces;

partial model Condenser_ACC "Base class for ACC"
  replaceable package CondMedium = ThermoPower.Water.StandardWater
    constrainedby Modelica.Media.Interfaces.PartialPureSubstance;
  replaceable package CoolMedium = Modelica.Media.Air.SimpleAir;
    //constrainedby Modelica.Media.Interfaces.PartialPureSubstance;
  //Nominal parameter
  parameter SI.MassFlowRate condNomFlowRate
    "Nominal flow rate through the condensing fluid side";
  parameter SI.MassFlowRate coolNomFlowRate
    "Nominal flow rate through the cooling fluid side";
  parameter SI.Pressure condNomPressure
    "Nominal pressure in the condensing fluid side inlet";
  parameter SI.Pressure coolNomPressure
    "Nominal pressure in the cooling fluid side inlet";

  //Physical Parameter
  parameter Integer N_cool=2 "Number of nodes of the cooling fluid side";
  parameter SI.Area condExchSurface
    "Exchange surface between condensing fluid - metal";
  parameter SI.Area coolExchSurface
    "Exchange surface between metal - cooling fluid";
  parameter SI.Volume condVol "Condensing fluid volume";
  parameter SI.Volume coolVol "Cooling fluid volume";
  parameter SI.Volume metalVol "Volume of the metal part in the tubes";
  parameter SI.SpecificHeatCapacity cm "Specific heat capacity of metal";
  parameter SI.Density rhoMetal "Density of metal";

  //Initialization conditions
  parameter SI.Pressure pstart_cond=condNomPressure
    "Condensing fluid pressure start value"
    annotation (Dialog(tab="Initialization"));
  parameter SI.Volume Vlstart_cond=condVol*0.15
    "Start value of the liquid water volume, condensation side"
    annotation (Dialog(tab="Initialization"));
  parameter Boolean SSInit=false "Steady-state initialization"
    annotation (Dialog(tab="Initialization"));

  Water.FlangeB waterOut(redeclare package Medium = CondMedium)
    annotation (Placement(transformation(extent={{-30,-120},{10,-80}},
          rotation=0)));
  Gas.FlangeA coolingIn(redeclare package Medium = CoolMedium)
    annotation (Placement(transformation(extent={{80,-60},{120,-20}},
          rotation=0)));
  Gas.FlangeB coolingOut(redeclare package Medium = CoolMedium)
    annotation (Placement(transformation(extent={{80,40},{120,80}},
          rotation=0)));
  Water.FlangeA steamIn(redeclare package Medium = CondMedium)
    annotation (Placement(transformation(extent={{-30,80},{10,120}},
          rotation=0)));

  annotation (Diagram(graphics), Icon(graphics={Rectangle(
                extent={{-100,100},{80,-60}},
                lineColor={0,0,255},
                fillColor={230,230,230},
                fillPattern=FillPattern.Solid),Rectangle(
                extent={{-90,-60},{70,-100}},
                lineColor={0,0,255},
                fillColor={230,230,230},
                fillPattern=FillPattern.Solid),Line(
                points={{100,-40},{-60,-40},{10,10},{-60,60},{100,60}},
                color={0,0,255},
                thickness=0.5),Text(
                extent={{-100,-113},{100,-143}},
                lineColor={85,170,255},
                textString="%name")}));
end Condenser_ACC;