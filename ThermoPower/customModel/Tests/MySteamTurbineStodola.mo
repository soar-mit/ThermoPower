within ThermoPower.customModel.Tests;

model MySteamTurbineStodola
  "Steam turbine: Stodola's ellipse law and constant isentropic efficiency"
  extends ThermoPower.Water.BaseClasses.SteamTurbineBase;
  parameter SI.PerUnit eta_iso_nom=0.92 "Nominal isentropic efficiency";
  parameter SI.Area Kt "Kt coefficient of Stodola's law";
  Medium.Density rho "Inlet density";
  
  Medium.SaturationProperties sat_out "Outlet Saturation properties";
  Medium.SpecificEnthalpy hl_out "Outlet Specific enthalpy of saturated liquid";
  Medium.SpecificEnthalpy hv_out "Outlet Specific enthalpy of saturated steam";
  Medium.MassFraction xout "Outlet steam quality";
  
  Medium.SaturationProperties sat_in "Inlet Saturation properties";
  Medium.SpecificEnthalpy hl_in "Inlet enthalpy of saturated liquid";
  Medium.SpecificEnthalpy hv_in "Inlet enthalpy of saturated steam";
  Medium.MassFraction xin "Inlet steam quality";
  
  parameter Boolean useWetnessCorrection = false "Apply Baumann's rule for isentropic eff. correction";
  parameter Boolean useMflowCorrection = false "Apply mass flow rate law for isentropic eff. correction";
  Real f_wetness "Wetness correction factor";
  Real f_mflow "Mass flow rate law correction factor";
  
equation
  rho =  Medium.density(steamState_in);
  w = homotopy(Kt*theta*sqrt(pin*rho)*ThermoPower.Functions.sqrtReg(1 - (1/PR)^2),
               theta*wnom/pnom*pin) "Stodola's law";
  
  sat_out.psat = pout;
  sat_out.Tsat = Medium.saturationTemperature(pout);
  hl_out = Medium.bubbleEnthalpy(sat_out);
  hv_out = Medium.dewEnthalpy(sat_out);
  xout = if hout<=hl_out then 0 else if hout>=hv_out then 1 else (hout-hl_out)/(hv_out-hl_out);
  
  sat_in.psat = pin;
  sat_in.Tsat = Medium.saturationTemperature(pin);
  hl_in = Medium.bubbleEnthalpy(sat_in);
  hv_in = Medium.dewEnthalpy(sat_in);
  xin = if hin<=hl_in then 0 else if hin>=hv_in then 1 else (hin-hl_in)/(hv_in-hl_in);
  
  f_wetness = if useWetnessCorrection then (1-(1-(xin+xout)/2)) else 1 "Baumann's rule with unity coefficient";
  f_mflow = if useMflowCorrection then (1-0.14*(1-w/wnom)^1.4) else 1 "Empirical law, from 'Dynamic modelling and control of a Small Modular Reactor in load following by cogeneration mode'";
  eta_iso = eta_iso_nom*f_wetness*f_mflow "Final isentropic efficiency";
  annotation (Documentation(info="<html>
<p>This model extends <tt>SteamTurbineBase</tt> by adding the actual performance characteristics:
<ul>
<li>Stodola's law
<li>Constant isentropic efficiency
</ul></p>
<p>The inlet flowrate is also proportional to the <tt>partialArc</tt> signal if the corresponding connector is wired. In this case, it is assumed that the flow rate is reduced by partial arc admission, not by throttling (i.e., no loss of thermodynamic efficiency occurs). To simulate throttling, insert a valve model before the turbine inlet.
</html>", revisions="<html>
<ul>
<li><i>20 Apr 2005</i>
  by <a href=\"mailto:francesco.casella@polimi.it\">Francesco Casella</a>:<br>
     First release.</li>
</ul>
</html>"));
end MySteamTurbineStodola;
