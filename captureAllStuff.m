% for getting out details and relationships to compare to errors
for i = 1:100
    load(['GCforModel_' num2str(i)]);
    if i == 1
        relationshipsAll = zeros([100 4 2]);
        detailsAll = zeros([100 4 3]);
    end
    
    if numrels ~=4
        relationships = [relationships ; zeros(4-numrels,2)];
        details = [details ; zeros(4-numrels,3)];
    end
    eval(['relationshipsAll(i,:,:) = relationships;']);
    eval(['detailsAll(i,:,:) = details;']);
    
end

%%
for dacount = 1:100
    load(['GCforModel_' num2str(dacount)]);
    GCPlotAll
end