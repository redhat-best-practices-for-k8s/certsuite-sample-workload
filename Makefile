.PHONY: install \
        clean

install: 
	bash ./deploy-all.sh
	
clean:
	bash ./clean-all.sh
