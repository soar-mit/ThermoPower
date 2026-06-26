within ThermoPower.customModel.Blocks;

block LimPID_Tinit "PID controller with initialization time and set/measure normalization"

  import Modelica.Blocks.Types.InitPID;
  import Modelica.Blocks.Types.Init;
  import Modelica.Blocks.Types.SimpleController;
  extends Modelica.Blocks.Interfaces.SVcontrol;
  // NEW PARAMETERS
  parameter Boolean useInitTime = false "Enable PID suppression during initialization period";
  parameter Modelica.SIunits.Time initTime = 0 "Time to start PID control [s]" annotation(
    Dialog(enable = useInitTime));
  parameter Real u_m_nom = 1 "Nominal value of measurement for normalization (u_m_eff = u_m / u_m_nom)";
  parameter Real u_s_nom = 1 "Nominal value of set normalization (u_s_eff = u_s / u_s_nom)";
  // Internal effective measurement (switched)
  Real u_m_eff "Effective measurement used by PID internals";
  Real u_s_eff "Effective set used by PID internals";
  output Real controlError = u_s_eff - u_m_eff "Control error (uses effective measurement)";
  // Standard LimPID parameters
  parameter Modelica.Blocks.Types.SimpleController controllerType = Modelica.Blocks.Types.SimpleController.PID "Type of controller";
  parameter Real k(min = 0, unit = "1") = 1 "Gain of controller";
  parameter Modelica.SIunits.Time Ti(min = Modelica.Constants.small) = 0.5 "Time constant of Integrator block" annotation(
    Dialog(enable = controllerType == Modelica.Blocks.Types.SimpleController.PI or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Modelica.SIunits.Time Td(min = 0) = 0.1 "Time constant of Derivative block" annotation(
    Dialog(enable = controllerType == Modelica.Blocks.Types.SimpleController.PD or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Real yMax(start = 1) "Upper limit of output";
  parameter Real yMin = -yMax "Lower limit of output";
  parameter Real wp(min = 0) = 1 "Set-point weight for Proportional block (0..1)";
  parameter Real wd(min = 0) = 0 "Set-point weight for Derivative block (0..1)" annotation(
    Dialog(enable = controllerType == Modelica.Blocks.Types.SimpleController.PD or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Real Ni(min = 100*Modelica.Constants.eps) = 0.9 "Ni*Ti is time constant of anti-windup compensation" annotation(
    Dialog(enable = controllerType == Modelica.Blocks.Types.SimpleController.PI or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Real Nd(min = 100*Modelica.Constants.eps) = 10 "The higher Nd, the more ideal the derivative block" annotation(
    Dialog(enable = controllerType == Modelica.Blocks.Types.SimpleController.PD or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Boolean withFeedForward = false "Use feed-forward input?" annotation(
    Evaluate = true,
    choices(checkBox = true));
  parameter Real kFF = 1 "Gain of feed-forward input" annotation(
    Dialog(enable = withFeedForward));
  parameter Modelica.Blocks.Types.InitPID initType = Modelica.Blocks.Types.InitPID.DoNotUse_InitialIntegratorState "Type of initialization" annotation(
    Evaluate = true,
    Dialog(group = "Initialization"));
  parameter Real xi_start = 0 "Initial or guess value for integrator output (= integrator state)" annotation(
    Dialog(group = "Initialization", enable = controllerType == Modelica.Blocks.Types.SimpleController.PI or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Real xd_start = 0 "Initial or guess value for state of derivative block" annotation(
    Dialog(group = "Initialization", enable = controllerType == Modelica.Blocks.Types.SimpleController.PD or controllerType == Modelica.Blocks.Types.SimpleController.PID));
  parameter Real y_start = 0 "Initial value of output" annotation(
    Dialog(enable = initType == Modelica.Blocks.Types.InitPID.InitialOutput, group = "Initialization"));
  parameter Modelica.Blocks.Types.LimiterHomotopy homotopyType = Modelica.Blocks.Types.LimiterHomotopy.Linear "Simplified model for homotopy-based initialization" annotation(
    Evaluate = true,
    Dialog(group = "Initialization"));
  parameter Boolean strict = false "= true, if strict limits with noEvent(..)" annotation(
    Evaluate = true,
    choices(checkBox = true),
    Dialog(tab = "Advanced"));
  parameter Boolean limitsAtInit = true "Has no longer an effect and is only kept for backwards compatibility" annotation(
    Dialog(tab = "Dummy"),
    Evaluate = true,
    choices(checkBox = true));
  constant Modelica.SIunits.Time unitTime = 1 annotation(
    HideResult = true);
  Modelica.Blocks.Interfaces.RealInput u_ff if withFeedForward "Optional connector of feed-forward input signal" annotation(
    Placement(transformation(origin = {60, -120}, extent = {{20, -20}, {-20, 20}}, rotation = 270)));
  Modelica.Blocks.Math.Add addP(k1 = wp, k2 = -1) annotation(
    Placement(transformation(extent = {{-80, 40}, {-60, 60}})));
  Modelica.Blocks.Math.Add addD(k1 = wd, k2 = -1) if with_D annotation(
    Placement(transformation(extent = {{-80, -10}, {-60, 10}})));
  Modelica.Blocks.Math.Gain P(k = 1) annotation(
    Placement(transformation(extent = {{-50, 40}, {-30, 60}})));
  Modelica.Blocks.Continuous.Integrator I(k = unitTime/Ti, y_start = xi_start, initType = if initType == InitPID.SteadyState then Init.SteadyState else if initType == InitPID.InitialState or initType == InitPID.DoNotUse_InitialIntegratorState then Init.InitialState else Init.NoInit) if with_I annotation(
    Placement(transformation(extent = {{-50, -60}, {-30, -40}})));
  Modelica.Blocks.Continuous.Derivative D(k = Td/unitTime, T = max([Td/Nd, 1.e-14]), x_start = xd_start, initType = if initType == InitPID.SteadyState or initType == InitPID.InitialOutput then Init.SteadyState else if initType == InitPID.InitialState then Init.InitialState else Init.NoInit) if with_D annotation(
    Placement(transformation(extent = {{-50, -10}, {-30, 10}})));
  Modelica.Blocks.Math.Gain gainPID(k = k) annotation(
    Placement(transformation(extent = {{20, -10}, {40, 10}})));
  Modelica.Blocks.Math.Add3 addPID annotation(
    Placement(transformation(extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Math.Add3 addI(k2 = -1) if with_I annotation(
    Placement(transformation(extent = {{-80, -60}, {-60, -40}})));
  Modelica.Blocks.Math.Add addSat(k1 = +1, k2 = -1) if with_I annotation(
    Placement(transformation(origin = {80, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
  Modelica.Blocks.Math.Gain gainTrack(k = 1/(k*Ni)) if with_I annotation(
    Placement(transformation(extent = {{0, -80}, {-20, -60}})));
  Modelica.Blocks.Nonlinear.Limiter limiter(uMax = yMax, uMin = yMin, strict = strict, limitsAtInit = limitsAtInit, homotopyType = homotopyType) annotation(
    Placement(transformation(extent = {{70, -10}, {90, 10}})));
protected
  parameter Boolean with_I = controllerType == SimpleController.PI or controllerType == SimpleController.PID annotation(
    Evaluate = true,
    HideResult = true);
  parameter Boolean with_D = controllerType == SimpleController.PD or controllerType == SimpleController.PID annotation(
    Evaluate = true,
    HideResult = true);
public
  Modelica.Blocks.Sources.Constant Dzero(k = 0) if not with_D annotation(
    Placement(transformation(extent = {{-40, 20}, {-30, 30}})));
  Modelica.Blocks.Sources.Constant Izero(k = 0) if not with_I annotation(
    Placement(transformation(extent = {{0, -55}, {-10, -45}})));
  Modelica.Blocks.Sources.Constant FFzero(k = 0) if not withFeedForward annotation(
    Placement(transformation(extent = {{30, -35}, {40, -25}})));
  Modelica.Blocks.Math.Add addFF(k1 = 1, k2 = kFF) annotation(
    Placement(transformation(extent = {{48, -6}, {60, 6}})));
initial equation
  if initType == InitPID.InitialOutput then
    gainPID.y = y_start;
  end if;
equation
  if initType == InitPID.InitialOutput and (y_start < yMin or y_start > yMax) then
    Modelica.Utilities.Streams.error("LimPID: Start value y_start (=" + String(y_start) + ") is outside of the limits of yMin (=" + String(yMin) + ") and yMax (=" + String(yMax) + ")");
  end if;
// ================================================================
// t < initTime: u_m_eff = u_s_eff (error = 0, integrator does not accumulate)
// ================================================================
  u_s_eff = u_s/u_s_nom;
  if useInitTime then
    u_m_eff = if time < initTime then u_s_eff else u_m/u_m_nom;
  else
    u_m_eff = u_m/u_m_nom;
  end if;
  
// ================================================================
// Assign u_s_eff directly insteaad of connect
// ================================================================
  addP.u1 = u_s_eff;
  if with_D then
    addD.u1 = u_s_eff;
  end if;
  if with_I then
    addI.u1 = u_s_eff;
  end if;
  //connect(u_s, addP.u1) annotation(
  //  Line(points = {{-120, 0}, {-96, 0}, {-96, 56}, {-82, 56}}, color = {0, 0, 127}));
  //connect(u_s, addD.u1) annotation(
  //  Line(points = {{-120, 0}, {-96, 0}, {-96, 6}, {-82, 6}}, color = {0, 0, 127}));
  //connect(u_s, addI.u1) annotation(
  //  Line(points = {{-120, 0}, {-96, 0}, {-96, -42}, {-82, -42}}, color = {0, 0, 127}));
  
  connect(addP.y, P.u) annotation(
    Line(points = {{-59, 50}, {-52, 50}}, color = {0, 0, 127}));
  connect(addD.y, D.u) annotation(
    Line(points = {{-59, 0}, {-52, 0}}, color = {0, 0, 127}));
  connect(addI.y, I.u) annotation(
    Line(points = {{-59, -50}, {-52, -50}}, color = {0, 0, 127}));
  connect(P.y, addPID.u1) annotation(
    Line(points = {{-29, 50}, {-20, 50}, {-20, 8}, {-12, 8}}, color = {0, 0, 127}));
  connect(D.y, addPID.u2) annotation(
    Line(points = {{-29, 0}, {-12, 0}}, color = {0, 0, 127}));
  connect(I.y, addPID.u3) annotation(
    Line(points = {{-29, -50}, {-20, -50}, {-20, -8}, {-12, -8}}, color = {0, 0, 127}));
  connect(limiter.y, addSat.u1) annotation(
    Line(points = {{91, 0}, {94, 0}, {94, -20}, {86, -20}, {86, -38}}, color = {0, 0, 127}));
  connect(limiter.y, y) annotation(
    Line(points = {{91, 0}, {110, 0}}, color = {0, 0, 127}));
  connect(addSat.y, gainTrack.u) annotation(
    Line(points = {{80, -61}, {80, -70}, {2, -70}}, color = {0, 0, 127}));
  connect(gainTrack.y, addI.u3) annotation(
    Line(points = {{-21, -70}, {-88, -70}, {-88, -58}, {-82, -58}}, color = {0, 0, 127}));

// ================================================================
// Connect u_m_eff (not u_m) to internal blocks
// ================================================================
  addP.u2 = u_m_eff;
  if with_D then
    addD.u2 = u_m_eff;
  end if;
  if with_I then
    addI.u2 = u_m_eff;
  end if;
  connect(Dzero.y, addPID.u2) annotation(
    Line(points = {{-29.5, 25}, {-24, 25}, {-24, 0}, {-12, 0}}, color = {0, 0, 127}));
  connect(Izero.y, addPID.u3) annotation(
    Line(points = {{-10.5, -50}, {-20, -50}, {-20, -8}, {-12, -8}}, color = {0, 0, 127}));
  connect(addPID.y, gainPID.u) annotation(
    Line(points = {{11, 0}, {18, 0}}, color = {0, 0, 127}));
  connect(addFF.y, limiter.u) annotation(
    Line(points = {{60.6, 0}, {68, 0}}, color = {0, 0, 127}));
  connect(gainPID.y, addFF.u1) annotation(
    Line(points = {{41, 0}, {44, 0}, {44, 3.6}, {46.8, 3.6}}, color = {0, 0, 127}));
  connect(FFzero.y, addFF.u2) annotation(
    Line(points = {{40.5, -30}, {44, -30}, {44, -3.6}, {46.8, -3.6}}, color = {0, 0, 127}));
  connect(addFF.u2, u_ff) annotation(
    Line(points = {{46.8, -3.6}, {44, -3.6}, {44, -92}, {60, -92}, {60, -120}}, color = {0, 0, 127}));
  connect(addFF.y, addSat.u2) annotation(
    Line(points = {{60.6, 0}, {64, 0}, {64, -20}, {74, -20}, {74, -38}}, color = {0, 0, 127}));
  annotation(
    defaultComponentName = "PID",
    Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Line(points = {{-80, 78}, {-80, -90}}, color = {192, 192, 192}), Polygon(lineColor = {192, 192, 192}, fillColor = {192, 192, 192}, fillPattern = FillPattern.Solid, points = {{-80, 90}, {-88, 68}, {-72, 68}, {-80, 90}}), Line(points = {{-90, -80}, {82, -80}}, color = {192, 192, 192}), Polygon(lineColor = {192, 192, 192}, fillColor = {192, 192, 192}, fillPattern = FillPattern.Solid, points = {{90, -80}, {68, -72}, {68, -88}, {90, -80}}), Line(points = {{-80, -80}, {-80, -20}, {30, 60}, {80, 60}}, color = {0, 0, 127}), Text(textColor = {192, 192, 192}, extent = {{-20, -20}, {80, -60}}, textString = "%controllerType"), Line(visible = strict, points = {{30, 60}, {81, 60}}, color = {255, 0, 0})}),
    Documentation(info = "<html>
<p>During t < initTime, the internal measurement is held equal to setpoint (error = 0), preventing integrator 
   accumulation. After initTime, normal PID operation. This is useful for initial steady-state calculations.
   
   Also, set and measure values can be normalized without separate Gain connector. Output value still needs to be scaled.</p>
</html>"));
end LimPID_Tinit;
