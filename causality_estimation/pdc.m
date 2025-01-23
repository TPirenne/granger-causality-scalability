function [cm, info] = pdc(data, info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PDC
%   From input time series, estimates a binary causal map using the
%   Partial Directed Coherence estimation method described in [1]. MVAR
%   parameters are estimated by the method in 'info.est_method'.
%   'info':
%       info.est_method: "SBL" | "OLS" | "LWR" | "LAPPS" | "LASSO"
%       info.order: integer
%       (info.prior): matrix (nc x nc) of prior knowledge on causal est.
%       XXX  info.pthresh: threshold for p-values to get binary causal map.
%       info.npdc: normalized PDC.
%       info.Patnaik_thresh: threshold calculated by Patnaik approximation
%
% [1] Baccala et. al. 2001
% =========================================================================
% MIT License                                                             %
%                                                                         %
% Copyright (c) 2025, Thomas Pirenne                                      %
%                                                                         %
% Permission is hereby granted, free of charge, to any person obtaining a %
% copy of this software and associated documentation files (the           %
% "Software"), to deal in the Software without restriction, including     %
% without limitation the rights to use, copy, modify, merge, publish,     %
% distribute, sublicense, and/or sell copies of the Software, and to      %
% permit persons to whom the Software is furnished to do so, subject to   %
% the following conditions:                                               %
%                                                                         %
% The above copyright notice and this permission notice shall be included %
% in all copies or substantial portions of the Software.                  %
%                                                                         %
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS %
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF              %
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  %
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY    %
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,    %
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE       %
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Parse parameters
    order = info.order;
    pthresh = 0.001;

    if ~isfield(info, "prior")
        info.prior = ones(size(data, 1));
    end

    if ~isfield(info, "nf")
        nf = 5;
    else
        nf = info.nf;
    end

    %% Full regression
    [A, pf, info] = estimate_var(data, order, info.prior, info);
    
    if isfield(info, "iterations")
        info.total_iterations = sum(info.iterations);
    end
    
    %% PDC -- from PDC by Baccala et. al. 2001
    % Constants
    % nf = 5;
    nc = size(data, 1);
    ns = size(data, 2);
    avalue = 1 - pthresh;       % 0.95;

    % Init variables
    SS   = zeros(nc, nc, nf);
    L    = zeros(nc, nc, nf);
    th   = zeros(nc, nc, nf);
    fvar = zeros(nc, nc, nf);

    % Init Euclidian metric
    pu = pinv(eye(nc));

    % Whatever that is
    Z = zmatrm(data, order);
    gamma = Z*Z';
    Omega = kron(inv(gamma), sqrt(pu)*pf*sqrt(pu)*ns);
    Omega_a = kron([1 1]'*[1 1], Omega);
    
    % For each frequency
    for fid = 0: nf - 1
        f = fid / (2 * nf);
        AL = eye(nc, nc);

        for iid = 1: order
            AL = AL - A(:,:,iid) * exp(-sqrt(-1) * 2 * iid * pi * f);
        end
        AT = pinv(AL);

        % Matrix C
        Cmat = [ ];
        Smat = [ ];

        for rid = 1: order
            divect = 2*pi*f*rid*ones(1,nc^2);
            cvector = cos(divect);
            svector = -sin(divect);
            Cmat = [Cmat diag(cvector)];
            Smat = [Smat diag(svector)];
        end
        Zmat = zeros(size(Cmat));
        Cjoint = [Cmat Zmat;Zmat -Smat];
        Ct = Cjoint*Omega_a*Cjoint';

        SU = AT*pf*AT';
        SS(:, :, fid+1) = SU;

        %%% 2
        for uid=1:nc
            for jid=1:nc
                % eigenvalue computation
                Co=[Ct((jid-1)*nc+uid,(jid-1)*nc+uid) ...
                    Ct((jid-1)*nc+uid,(nc+jid-1)*nc+uid);
                    Ct((nc+jid-1)*nc+uid,(jid-1)*nc+uid)  ...
                    Ct((nc+jid-1)*nc+uid,(nc+jid-1)*nc+uid)];
                v=eig(Co);
                
                Pat=gaminv(avalue,.5*sum(v)^2/(2*v'*v),2);
    
                L(uid,jid,fid+1)=AL(uid,jid)/sqrt(AL(:,jid)'*pu*AL(:,jid));
                nL(uid,jid,fid+1)=AL(uid,jid);
                dL(uid,jid,fid+1)=AL(:,jid)'*pu*AL(:,jid);

                dLu=abs(dL(uid,jid,fid+1));
                nLu=abs(nL(uid,jid,fid+1))^2;
                th(uid,jid,fid+1)=sqrt(Pat/((sum(v)/(2*v'*v))* ...
                  (ns*abs(dL(uid,jid,fid+1)))));

                I_ij=zeros(nc^2,nc^2);
                I_j=I_ij;
                I_ij((jid-1)*nc+uid,(jid-1)*nc+uid)=1;
                I_j((jid-1)*nc+1:jid*nc,(jid-1)* ...
                  nc+1:jid*nc)=1;
                I_j=diag(diag(I_j));
                Icj=[I_j zeros(size(I_j)); zeros(size(I_j)) I_j];
                Ic=[I_ij zeros(size(I_ij)); zeros(size(I_ij)) I_ij];

                rr=reshape(AL,nc^2,1);
                a=[real(rr); imag(rr)];
                G=2*((Ic*a)/(dLu)-(Icj*a*nLu)/(dLu)^2);
                fvar(uid,jid,fid+1)=G'*Ct*G;
            end
        end
    end

    % Out [SS, L, th, fvar]

    %% CM from PDC values above Patenaik calculated threshold from any fre.
    % Significant PDC/DTF/DC/PC/Coh values on frequency scale
    cm = real(((abs(L).^2 - th.^2) > 0) .* 1 + ((abs(L).^2 - th.^2) <= 0) .* 0);
    cm = double(any(cm, 3)');

    % Diagonal to NaN because we do not try to predict autocausality
    cm = double(cm);
    cm(1:size(cm,1) + 1:end) = NaN;

    %% Output
    % Log info
    info.npdc = L;
    info.Patnaik_thresh = th;
end

%% Utils
function Z = zmatrm(Y, p)
    [K T] = size(Y);
    y1 = [zeros(K*p,1); reshape(flipud(Y),K*T,1)];
    Z =  zeros(K*p, T);
    for i=0:T-1
       Z(:, i+1)=flipud(y1(1+K*i:K*i+K*p));
    end
end