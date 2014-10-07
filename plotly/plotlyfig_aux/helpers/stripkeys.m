function stripped = stripkeys(obj, fields, fieldname, key)

%plorlt reference
pr = obj.PlotlyReference; 

% initialize output
stripped = fields;

% get fieldnames
fn = fieldnames(stripped);
fnmod = fn;

try
    
    for d = 1:length(fn);
        
        % clean up axis keys
        if any(strfind(fn{d},'xaxis')) || any(strfind(fn{d},'yaxis'))
            fnmod{d} = fn{d}(1:length('_axis'));
        end
        
        % keys:(object, style, plot_info, data)
        keytype = getfield(pr,fieldname,fnmod{d},'key_type');
        
        % check for objects
        if strcmp(keytype,'object')
            
            % clean up font keys
            if any(strfind(fn{d},'font'))
                fnmod{d} = 'font';
            end
            
            % handle annotations
            if strcmp(fn{d},'annotations')
                annot = getfield(stripped, fn{d});
                fnmod{d} = 'annotation';
                for a = 1:length(annot)
                    %recursive call to stripkeys
                    stripped.annotations{a} = stripkeys(obj, annot{a}, fnmod{d}, key);
                end
            else
                %recursive call to stripkeys
                stripped = setfield(stripped, fn{d}, stripkeys(obj, getfield(stripped, fn{d}), fnmod{d}, key));
            end
            
            % look for desired key
        elseif any(strcmp(keytype, key))
            stripped = rmfield(stripped, fn{d});
        end
        
    end
    
    %----CLEAN UP----%
    remfn = fieldnames(stripped);
    
    for n = 1:length(remfn)
        if isstruct(getfield(stripped,remfn{n}))
            if isempty(fieldnames(getfield(stripped,remfn{n})))
                stripped = rmfield(stripped,remfn{n});
            end
        elseif isempty(getfield(stripped,remfn{n}))
            stripped = rmfield(stripped,remfn{n});
        end
    end
    
catch exception
    
    if obj.UserData.Verbose
        fprintf(['\nWhoops! ' exception.message '\n\n']);
    end
    
end
