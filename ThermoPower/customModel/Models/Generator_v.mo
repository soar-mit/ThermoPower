within ThermoPower.customModel.Models;

model Generator_v "Active power generator"
  parameter SI.Power Pnom "Nominal/rated power of the generator";
  parameter SI.Time Ta = 10 "Acceleration time of the turbo-generator group";
  parameter Integer Np=2 "Number of electrical poles"
    annotation(Evaluate = true);
  parameter SI.PerUnit eta = 1 "Electrical conversion efficiency";
  final parameter SI.AngularVelocity omega_e_nom = 2*pi*system.fnom "Nominal angular velocity of voltage vector";
  final parameter SI.AngularVelocity omega_m_nom = 2*pi*system.fnom/Np "Nominal angular velocity of turbo-group";
  final parameter SI.MomentOfInertia J = Pnom*Ta/omega_m_nom^2 "Turbo-generator group moment of inertia";
  parameter SI.PerUnit D = 0.01 "Damping coefficient";
  parameter SI.Time Tf = 1 "Time constant of omega_e_filt";
  final parameter SI.Torque tau_d = 2*D*Pnom*sqrt(Ta/omega_m_nom);
  parameter Boolean referenceGenerator = false "Set to true if reference generator in a synchronous island";
  parameter SI.Frequency fstart=system.fnom "Start value of the electrical frequency"
    annotation (Dialog(tab="Initialization"));
  parameter SI.Angle thetastart = 0 "Start value of the voltage phasor angle"
    annotation (Dialog(tab="Initialization"));
  parameter ThermoPower.Choices.Init.Options initOpt=system.initOpt
    "Initialization option" annotation (Dialog(tab="Initialization"));
  constant Real pi = Modelica.Constants.pi;

  // changed part
  outer System system "System object";

  SI.Angle theta(start = thetastart) "Voltage angle";
  SI.Angle phi "Shaft angle";
  SI.Torque tau "Torque at shaft";
  SI.AngularVelocity omega_m(start=2*pi*fstart/Np) "Angular velocity of the shaft";
  SI.AngularVelocity omega_e(start=2*pi*fstart) "Angular velocity of the voltage phasor";
  SI.Frequency f "Electrical frequency";
  SI.Power Pm "Mechanical power";
  SI.ActivePower Pe "Electrical Power";
  SI.ActivePower Pd "Damping power";
  SI.AngularVelocity omega_e_filt "Low-pass filtered angular velocity of the voltage phasor";
  SI.AngularVelocity de = omega_e - omega_e_filt;
  ThermoPower.Electrical.PowerConnection port annotation (Placement(transformation(extent=
           {{72,-14},{100,14}}, rotation=0)));
  Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft annotation (
      Placement(transformation(extent={{-100,-14},{-72,14}}, rotation=0)));
equation
  theta = Np*phi;
  der(phi) = omega_m;
  der(theta) = omega_e;
  f = omega_e/(2*pi);
  Pm = omega_m*tau;
  Pd = tau_d*(omega_e - omega_e_filt);
  J*der(omega_m)*omega_m  = Pm - Pd - Pe/eta;
  Tf*der(omega_e_filt) + omega_e_filt = omega_e;

  // Boundary conditions
  phi = shaft.phi;
  tau = shaft.tau;
  theta = port.theta;
  Pe = -port.P;
initial equation
  der(omega_e_filt) = 0;
  if initOpt == ThermoPower.Choices.Init.Options.noInit then
    // do nothing
  elseif initOpt == ThermoPower.Choices.Init.Options.steadyState then
    if referenceGenerator then
      theta = 0;
    else
      der(theta) = omega_e_nom;
    end if;
    der(omega_m) = 0;
  elseif initOpt == ThermoPower.Choices.Init.Options.fixedState then
    theta = thetastart;
    omega_e = 2*pi*fstart;
  else
    assert(false, "Unsupported initialisation option");
  end if;
  annotation (
    Icon(graphics={Rectangle(
              extent={{-72,6},{-48,-8}},
              lineColor={0,0,0},
              fillPattern=FillPattern.HorizontalCylinder,
              fillColor={160,160,164}),Ellipse(
              extent={{50,-50},{-50,50}},
              lineColor={0,0,0},
              lineThickness=0.5,
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),Line(points={{50,0},{72,0}},
          color={0,0,0}),Text(
              extent={{-26,24},{28,-28}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              textString="G")}),
    Documentation(info="<html>
<p>Same generator model except 'System system -> outer System system'. Without this change, nominal frequency other than 50Hz cause error.
</html>",   revisions="<html>
<ul>
<li><i>21 Feb 2019</i>
  by <a href=\"mailto:francesco.casella@polimi.it\">Francesco
Casella</a>:<br>
     Rewrote from scratch.</li>
</ul>
</html>"));
end Generator_v;
