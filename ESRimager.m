classdef ESRimager < handle
    properties
        h
        axislabels
        foldertextbox % Text box for displaying the folder of the images
        folderbutton % Button for popping a window to select the folder
        plotbutton % Button for executing the function that generates the plot
        binningtextbox % Text box for specifying the binning 
        mftextbox   % Text box for specifying the median filter 
        angletextbox % Text box for specifying the slicing angle
        credits % Text for displaying the creator information
        savebutton % Button for saving the figure
        binninglabel
        mflabel
        anglelabel
        th=0.35;
        nb_slice=100;
        a=10;
        b=10;
    end
    methods
    function obj = ESRimager()
        % Create the GUI elements
        obj.foldertextbox = uicontrol('Style', 'edit');
        obj.folderbutton = uicontrol('Style', 'pushbutton', 'String', 'Select Folder');
        obj.plotbutton = uicontrol('Style', 'pushbutton', 'String', 'Generate Plot');
        obj.binningtextbox = uicontrol('Style', 'edit');
        obj.mftextbox = uicontrol('Style', 'edit');
        obj.angletextbox = uicontrol('Style', 'edit');
        obj.credits = uicontrol('Style', 'text', 'String', 'Created by Ari and Charles');
        obj.savebutton = uicontrol('Style', 'pushbutton', 'String', 'Save Figure');
        obj.binninglabel=uicontrol('Style', 'text', 'String', 'BINNING');
        obj.mflabel=uicontrol('Style', 'text', 'String', 'MED FILT');
        obj.anglelabel=uicontrol('Style', 'text', 'String', 'ANGLE');
        % Set the callback functions for the GUI elements
        set(obj.folderbutton, 'Callback', @obj.selectFolder);
        set(obj.plotbutton, 'Callback', @obj.generatePlot);
        set(obj.savebutton, 'Callback', @obj.saveFigure);
        % Position the GUI elements
        %set(obj.plot, 'Position', [10 40 250 200]);
        set(obj.foldertextbox, 'Position', [10 10 100 20]);
        set(obj.folderbutton, 'Position', [120 10 100 20]);
        set(obj.plotbutton, 'Position', [340 10 100 20]);
        set(obj.binningtextbox, 'Position', [10 40 100 20]);
        set(obj.binninglabel,'Position', [120 40 100 20]);
        set(obj.mftextbox, 'Position', [10 60 100 20]);
        set(obj.mflabel, 'Position', [120 60 100 20]);
        set(obj.angletextbox, 'Position', [10 100 100 20]);
        set(obj.anglelabel, 'Position', [120 100 100 20]);
        set(obj.credits, 'Position', [230 30 150 20]);
        set(obj.savebutton, 'Position', [390 30 100 20]);
    end

    function selectFolder(obj, hObject, eventdata)
        % Open a dialog box to select the folder
        folder = uigetdir();
        % Set the text in the textBox2 to the selected folder
        set(obj.foldertextbox, 'String', folder);
    end

    function generatePlot(obj, hObject, eventdata)
        % Get the folder, binning, and median filter parameters from the text boxes
        folder = get(obj.foldertextbox, 'String');
        binning = str2num(get(obj.binningtextbox, 'String'));
        medianFilter = str2num(get(obj.mftextbox, 'String'));
        angle = str2num(get(obj.angletextbox, 'String'));
        % Call the function that generates the plot
        Sz=medianFilter;
        folder = cat(2,folder,'\');
        trialpath=folder;
        S = dir(folder);
        Nsubfolder=sum([S(~ismember({S.name},{'.','..'})).isdir]);
        datadir=cat(2,trialpath,'\1\DATA\');
        DataFolderinfo = dir(datadir);
        Samplefile=DataFolderinfo(3).name;
        Samplefileloc=cat(2,datadir,Samplefile);
        im1=imread(Samplefileloc);
        sli=slice_rect(im1,obj.nb_slice,angle);
        Nb_f=length(DataFolderinfo)-2;
        PLcell_ESR=get_esr_dem_ang(folder, Nsubfolder, Nb_f, sli,obj.th);
        Ccell_ESR=get_esr_maps(folder,Sz,PLcell_ESR);
        xf = Ccell_ESR{1}./1e9;
        M= Ccell_ESR{2};
        SizeSample=size(im1);
        W=SizeSample(1);
        H=SizeSample(2);
        largesize = max([W H]);
        yf100 = linspace(0,largesize,obj.nb_slice);
        Mmean=mean(M(10:end-10,obj.b:end-obj.b));
        % plot(obj.h.axes1,f, R,'b',f, I,'r',f, M,'k')
        % Update the plot
        plot(obj.h.axes1,xf(b:end-b),Mmean)
        xlabel(obj.h.axes1,'Frequency (GHz)')
        ylabel(obj.h.axes1,'PL signal (au)')
        %plot(xf(b:end-b),Mmean);
        %set(obj.plot, 'XLabel', obj.axislabels{1}, 'YLabel', obj.axislabels{2});
    end
    function saveFigure(obj, hObject, eventdata)
    % Get the figure handle
    fig = obj.plot.figure;
    % Get the filename from the user
    [filename, pathname] = uiputfile('*.png', 'Save Figure');
    % If the user cancels, return
    if filename == 0
        return;
    end

    % Save the figure to the specified file
    saveas(fig, fullfile(pathname, filename));
    end
    end
end