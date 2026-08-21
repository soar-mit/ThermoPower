within ThermoPower.customModel.Tests;

model asdfff
  ThermoPower.Water.SourceMassFlow sourceMassFlow1(redeclare package Medium = ThermoPower.Water.StandardWater, T = 423.15, h = 2736444, use_T = false, w0 = 100) annotation(
    Placement(transformation(origin = {-52, 60}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure1(T = 383.15, h = 417503, p0(displayUnit = "bar") = 1e5, use_T = false) annotation(
    Placement(transformation(origin = {-52, -2}, extent = {{10, -10}, {-10, 10}})));
  ThermoPower.Water.Flow1DFV2ph InletPart1(A = 0.2, DynamicMomentum = false, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Colebrook, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, L = 3, N = 3, Nt = 1, dpnom(displayUnit = "Pa") = 15000, e = 0.00015, hstartin = 2736444, hstartout = 2736444, noInitialPressure = false, omega = 1.57, p(displayUnit = "Pa"), pstart(displayUnit = "bar") = 1e5, wnf = 0.5, wnm = 0.1, wnom = 100) annotation(
    Placement(transformation(origin = {-20, 60}, extent = {{10, -10}, {-10, 10}}, rotation = 180)));
  ThermoPower.Water.Flow1DFV2ph OutletPart1(A = 0.2, DynamicMomentum = false, FFtype = ThermoPower.Choices.Flow1D.FFtypes.Colebrook, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Liquid, L = 3, N = 3, Nt = 1, dpnom(displayUnit = "Pa") = 15000, e = 0.00015, hstartin = 417503, hstartout = 417503, noInitialPressure = false, omega = 1.57, p(displayUnit = "Pa"), pstart(displayUnit = "bar") = 1e5, wnf = 0.5, wnm = 0.1, wnom = 100) annotation(
    Placement(transformation(origin = {-20, -2}, extent = {{-10, -10}, {10, 10}}, rotation = -180)));
  LumpedCondenser2 lumpedCondenser2(p = 1e5)  annotation(
    Placement(transformation(origin = {10, 28}, extent = {{-10, -10}, {10, 10}})));
  inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
    Placement(transformation(origin = {78, 78}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(sourceMassFlow1.flange, InletPart1.infl) annotation(
    Line(points = {{-42, 60}, {-30, 60}}, color = {0, 0, 255}));
  connect(OutletPart1.outfl, sinkPressure1.flange) annotation(
    Line(points = {{-30, -2}, {-42, -2}}, color = {0, 0, 255}));
  connect(InletPart1.outfl, lumpedCondenser2.steamIn) annotation(
    Line(points = {{-10, 60}, {10, 60}, {10, 38}}, color = {0, 0, 255}));
  connect(lumpedCondenser2.waterOut, OutletPart1.infl) annotation(
    Line(points = {{10, 18}, {8, 18}, {8, -2}, {-10, -2}}, color = {0, 0, 255}));
end asdfff;