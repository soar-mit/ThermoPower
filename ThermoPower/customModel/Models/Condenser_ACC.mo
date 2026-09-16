within ThermoPower.customModel.Models;

model Condenser_ACC "Condenser"
  extends ThermoPower.customModel.Interfaces.Condenser_ACC;
  parameter SI.CoefficientOfHeatTransfer gamma_cond
    "Coefficient of heat transfer on condensation surfaces";
  parameter SI.CoefficientOfHeatTransfer gamma_cool
    "Coefficient of heat transfer of cooling fluid side";
  parameter Choices.Flow1D.FFtypes FFtype_cool=Choices.Flow1D.FFtypes.NoFriction
    "Friction Factor Type";
  parameter Choices.Flow1D.HCtypes HCtype_cool=Choices.Flow1D.HCtypes.Downstream
    "Location of the hydraulic capacitance";
  parameter SI.Pressure dpnom_cool=0
    "Nominal pressure drop (friction term only!)";
  parameter SI.Density rhonom_cool=0 "Nominal inlet density";

  //other data
  constant Real pi=Modelica.Constants.pi;
  Thermal.ConvHT convHT(gamma=gamma_cool, N=N_cool) annotation (Placement(
        transformation(
        origin={-22,10},
        extent={{-10,-10},{10,10}},
        rotation=90)));
  CondenserShell_v condenserShell(
    redeclare package Medium = CondMedium,
    V=condVol,
    Mm=metalVol*rhoMetal,
    Ac=condExchSurface,
    Af=coolExchSurface,
    cm=cm,
    hc=gamma_cond,
    Nc=N_cool,
    pstart=pstart_cond,
    Vlstart=Vlstart_cond,
    initOpt=if SSInit then Choices.Init.Options.steadyState else Choices.Init.Options.noInit)
    annotation (Placement(transformation(extent={{-66,-6},{-34,26}},
          rotation=0)));
  Modelica.Blocks.Interfaces.RealOutput ratio_VvonVtot annotation (
      Placement(transformation(
        origin={-100,10},
        extent={{-10,-10},{10,10}},
        rotation=180)));
  Gas.Flow1D flowCooling(redeclare package Medium = CoolMedium, N = N_cool, Nt = 1, L = coolExchSurface^2/(coolVol*pi*4), A = (coolVol*4/coolExchSurface)^2/4*pi, omega = coolVol*4/coolExchSurface*pi, Dhyd = coolVol*4/coolExchSurface, wnom = coolNomFlowRate, FFtype = FFtype_cool, dpnom = dpnom_cool, HydraulicCapacitance = HCtype_cool)  annotation(
    Placement(transformation(origin = {39, 9}, extent = {{-11, -11}, {11, 11}}, rotation = 90)));
equation
  connect(condenserShell.steam, steamIn) annotation(
    Line(points = {{-50, 26}, {-50, 100}, {-10, 100}}, thickness = 0.5, color = {0, 0, 255}));
  connect(condenserShell.condensate, waterOut) annotation(
    Line(points = {{-50, -6}, {-50, -100}, {-10, -100}}, thickness = 0.5, color = {0, 0, 255}));
  connect(condenserShell.coolingFluid, convHT.side1) annotation(
    Line(points = {{-50, 10}, {-46, 10}, {-40, 10}, {-25, 10}}, color = {255, 127, 0}));
  connect(condenserShell.ratio_VvVtot, ratio_VvonVtot) annotation(
    Line(points = {{-61.2, 10}, {-100, 10}}, color = {0, 0, 127}));
  connect(convHT.side2, flowCooling.wall) annotation(
    Line(points = {{-18, 10}, {34, 10}}, color = {255, 127, 0}));
  connect(coolingIn, flowCooling.infl) annotation(
    Line(points = {{100, -40}, {40, -40}, {40, -2}}));
  connect(flowCooling.outfl, coolingOut) annotation(
    Line(points = {{40, 20}, {40, 60}, {100, 60}}, color = {159, 159, 223}));
  annotation (Diagram(graphics), Icon(graphics));
end Condenser_ACC;