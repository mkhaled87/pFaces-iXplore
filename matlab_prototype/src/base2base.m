function Nend = base2base(Nstart,bstart,bend)
  % base2base: convert numbers stored in one base directly into a second number base
  % usage: Nend = base2base(Nstart,bstart,bend)
  % 
  % arguments: (input)
  %  Nstart = a vector of "digits" that represent the number in
  %           the starting number base. The units digit is the last
  %           element, with the highest order digits coming first.
  %           if bstart is no larger then 36, these may be the
  %           characters '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
  %           If Nstart is an array, then each row of Nstart
  %           represents one number.
  %
  %           For those who stubbornly insist on conerting to or
  %           from a base that is higher than 36, this is possible
  %           as long as the digits of Nstart are stored in an
  %           un-encoded form. So Nstart must be a numeric vector
  %           or array that contains integers between 0 and bstart-1.
  %           In that event, the output from base2base will also be
  %           returned in unencoded form.
  %
  %           Note that this second mode of operation is inconsistent
  %           with how the built-in tools like dec2bin, dec2base
  %           and base2dec all work.
  %
  %  bstart = (scalar) numeric base for the number in Nstart
  %           bstart must be an integer between 2 and 36.
  % 
  %  bend =   (scalar) target base for the output result
  %           bend must be an integer between 2 and 36.
  %
  %
  % arguments: (output)
  %  Nend = representation of the number(s), converted into base bend.
  %
  % Example: Convert decimal numbers 0:10 from base 2 into base 3
  % Nstart = dec2bin(0:10)
  % Nstart =
  % 0000
  % 0001
  % 0010
  % 0011
  % 0100
  % 0101
  % 0110
  % 0111
  % 1000
  % 1001
  % 1010
  %
  % Nend = base2base(Nstart,2,3)
  % Nend =
  % 000
  % 001
  % 002
  % 010
  % 011
  % 012
  % 020
  % 021
  % 022
  % 100
  % 101
  %
  % Example: base conversion for a really large number (conversion was verifed using vpi2base)
  % base2base('1234567890123456789012345678901234567890123456789012345678901234567890',10,8)
  % ans =
  % 26712730460557502321115663104163350570542770265664630627263177431331617605322
  %
  % Example: hex to binary
  % base2base('FFFBC1234A',16,2)
  % ans =
  % 1111111111111011110000010010001101001010
  %
  % Example: conversion from base 10 to base 1000
  % base2base([1 2 3 4 5 6 7 8 9 1 2 3 4 5 6 7 8 9],10,1000)
  % ans =
  %    123   456   789   123   456   789
  %
  % Example: conversion between two bases, both of which are larger than 36
  % base2base([233 455 876 342 645],1000,100)
  % ans =
  %      2    33    45    58    76    34    26    45
  %
  % Author: John D'Errico
  % e-mail: woodchips@rochester.rr.com
  % Release: 1.0
  % Release date: 8/24/2016
  
  % digit encoding table:
  digenc = char([48:57,65:90]);
  
  encoding = true;
  if ~ischar(Nstart)
    encoding = false;
  end
  
  % verify that bstart and bend are both integers in the range 2:36
  if ~isnumeric(bstart) || ~isnumeric(bend) || (bstart < 2) || ...
      (bend < 2) || rem(bstart,1) || rem(bend,1)
    error('bstart and bend must be integer >= 2.')
  end
  if encoding && ((bstart > 36) || (bend > 36))
    error('Character encoded input and output requires bstart and bend may not exceed 36')
  end
  
  %check that the number does indeed lie in base bstart
  if encoding && any(~ismember(Nstart,digenc(1:bstart)))
    error(['Nstart must contain digits in base bstart (',num2str(bstart),'), thus from the set: ''',digenc(1:bstart),''''])
  elseif ~encoding && (any(Nstart < 0) || any(Nstart >= bstart))
    error(['Nstart must contain digits in base bstart (',num2str(bstart),'), thus from the set: 0:',num2str(bstart-1)])
  end
  
  % convert character form digits into numeric digits
  if encoding
    Nstartd = Nstart - '0';
    ind = (Nstartd > 9);
    Nstartd(ind) = Nstartd(ind) - 7;
  else
    % un-character-encoded input
    Nstartd = Nstart;
  end
    
  % check to see if the conversion can be done using decimal as the
  % intermediate base.
  [n,ndigits] = size(Nstart);
  % if this overflows, we will get an inf. But the test below will catch
  % that event.
  D = Nstartd*bstart.^(ndigits-1:-1:0).';
  
  if max(D) < 2^53
    % be lazy and fast, using decimal as an intermediate representation
    % I could have been even lazier here, and used base2dec followed by
    % dec2base. This is not difficult though, and might be useful for
    % a student to follow.
    
    % how many base bend digits will this require?
    if any(D > 0)
      ndigitsend = 1 + floor(log(max(D))/log(bend));
    else
      ndigitsend = 1;
    end
    
    % pre-allocate Nend
    Nend = zeros(n,ndigitsend);
    
    % strip off each digit in the target base
    i = 0;
    while any(D > 0)
      i = i + 1;
      Nend(:,i) = mod(D,bend);
      % the divide is known to have an integer result here. no need to
      % worry about a non-zero remainder, because we subtract off the mod.
      D = (D - Nend(:,i))/bend;
    end
    Nend = fliplr(Nend);
    
  else
    % the numbers are too large to work with using base 10 as
    % an intermediate base.
    
    % first, how many digits will we require?
    ndigitsend = ceil(log(bstart)*(ndigits+1)/log(bend));
    
    % pre-allocate Nend
    Nend = zeros(n,ndigitsend);
    
    % to do the conversion, start by writing
    % the number bstart^0 as a string of base bend digits.
    % that part is easy, because 1 is just 1, in any base.
    bconv = zeros(1,ndigitsend);
    % put the units digit at the end.
    % think of bconv as bstart^(i-1) in the loop that follows,
    % but it will be represented in terms of base bend
    bconv(end) = 1;
    
    % loop over each base bstart digit in Nstart
    for i = 1:ndigits
      % add in multiples of bconv, as many as are indicated by Nstart
      % for this power.
      Nend = Nend + Nstartd(:,ndigits - i +1)*bconv;
      
      % do carries on Nend
      [Nend,overcarries] = carryfun(Nend,bend);
      if overcarries
        bconv = [zeros(1,overcarries),bconv];
      end
      
      if i < ndigits
        % multiply bconv by bstart, then do a carry in base bend
        bconv = bconv*bstart;
        [bconv,overcarries] = carryfun(bconv,bend);
        if overcarries
          Nend = [zeros(n,overcarries),Nend];
        end
      end
    end
    
    % are there any leading zero digits in the final result?
    % find the first non-zero element of Nend over all rows of Nend
    % (just in case n > 1)
    k = find(any(Nend,1),1,'first');
    if k > 1
      Nend(:,1:(k-1)) = [];
    end
    
  end
  
  % convert Nend back into character form using the lookup table in
  % digenc.
  if encoding && (bend <= 36)
    Nend = digenc(Nend + 1);
  end
  
  % =============
  %
  % =============
  
  function [diglist,overcarries] = carryfun(diglist,b)
    % assume diglist is a number in base b
    
    % overcarries is the number of extra digits that were
    % introduced by the carries.
    overcarries = 0;
    k = 1;
    while ~isempty(k)
      [m,k] = find(diglist >= b);
      
      % did a carry happen on the highest order digit?
      if min(k) == 1
        overcarries = overcarries + 1;
        diglist = [zeros(size(diglist,1),1),diglist];
        k = k + 1;
      end
      
      carry = floor(diglist(m,k)/b);
      
      diglist(m,k) = diglist(m,k) - carry*b;
      diglist(m,k-1) = diglist(m,k-1) + carry;
    end
  end
end
